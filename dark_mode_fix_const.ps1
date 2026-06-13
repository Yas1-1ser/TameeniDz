
# Fix const errors and undefined context issues from dark mode migration
$targetDir = "d:\tameenidz\lib"

$files = Get-ChildItem -Path $targetDir -Filter "*.dart" -Recurse

$changedCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content

    if ($content -notmatch 'context\.colors') { continue }

    $lines = $content -split "`n"
    
    # Pass 1: Remove const from any line or parent const that contains context.colors
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match 'context\.colors') {
            # Remove const keyword on the same line before constructors/values
            $lines[$i] = $line -replace '\bconst\s+', ''
        }
    }
    
    # Pass 2: Remove const from parent lines where child lines use context.colors
    # e.g. "const SizedBox(" on line N, "color: context.colors.xxx" on line N+3
    # We need to find const on opening widget lines and check if any child uses context.colors
    $content = $lines -join "`n"
    
    # Remove 'const ' before widget constructors when the block contains context.colors
    # Pattern: const WidgetName( ... context.colors ... )
    # Use a simple heuristic: if a line has 'const ' + constructor and within next 15 lines there's context.colors
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*const\s+\w+\(') {
            # Check next 20 lines for context.colors
            $endCheck = [Math]::Min($i + 20, $lines.Count - 1)
            $bracketDepth = 0
            $foundContextColors = $false
            for ($j = $i; $j -le $endCheck; $j++) {
                if ($lines[$j] -match 'context\.colors') { $foundContextColors = $true; break }
                $bracketDepth += ($lines[$j].ToCharArray() | Where-Object { $_ -eq '(' }).Count
                $bracketDepth -= ($lines[$j].ToCharArray() | Where-Object { $_ -eq ')' }).Count
                if ($j -gt $i -and $bracketDepth -le 0) { break }
            }
            if ($foundContextColors) {
                $lines[$i] = $lines[$i] -replace '\bconst\s+', ''
            }
        }
    }
    
    $content = $lines -join "`n"

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $changedCount++
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "`nDone! Fixed $changedCount files."
