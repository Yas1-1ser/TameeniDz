
# Fix Phase 2: Handle undefined_identifier and remaining invalid_constant errors
# For undefined context: revert context.colors.xxx back to AppColors.xxx on those specific lines
# For invalid_constant: more aggressive const removal

$targetDir = "d:\tameenidz\lib"

# Get error locations from dart analyze
$analyzeOutput = dart analyze lib 2>&1 | Out-String

# --- Part 1: Fix undefined_identifier errors ---
# Parse lines with undefined_identifier for 'context'
$undefinedLines = @{}
$analyzeOutput -split "`n" | ForEach-Object {
    if ($_ -match '^\s+error - (.+?):(\d+):\d+ - Undefined name .context.' -or
        $_ -match '^\s+error - (.+?):(\d+):\d+.*undefined_identifier') {
        $file = $matches[1] -replace '\\', '/'
        $lineNum = [int]$matches[2]
        $fullPath = Join-Path "d:\tameenidz" $file
        if (-not $undefinedLines.ContainsKey($fullPath)) {
            $undefinedLines[$fullPath] = @()
        }
        $undefinedLines[$fullPath] += $lineNum
    }
}

# Reverse mapping
$reverseMap = @{
    'context.colors.beigeBg' = 'AppColors.beigeBg'
    'context.colors.beigeCard' = 'AppColors.beigeCard'
    'context.colors.beigeDeep' = 'AppColors.beigeDeep'
    'context.colors.warmDivider' = 'AppColors.warmDivider'
    'context.colors.darkText' = 'AppColors.darkText'
    'context.colors.onSurface' = 'AppColors.onSurface'
    'context.colors.onSurfaceVariant' = 'AppColors.onSurfaceVariant'
    'context.colors.slate100' = 'AppColors.slate100'
    'context.colors.slate200' = 'AppColors.slate200'
    'context.colors.slate300' = 'AppColors.slate300'
    'context.colors.slate400' = 'AppColors.slate400'
    'context.colors.slate500' = 'AppColors.slate500'
    'context.colors.slate700' = 'AppColors.slate700'
    'context.colors.offWhite' = 'AppColors.offWhite'
    'context.colors.softSlate' = 'AppColors.softSlate'
    'context.colors.background' = 'AppColors.background'
    'context.colors.surface' = 'AppColors.surface'
    'context.colors.surfaceContainer' = 'AppColors.surfaceContainer'
    'context.colors.surfaceContainerHigh' = 'AppColors.surfaceContainerHigh'
    'context.colors.surfaceContainerLowest' = 'AppColors.surfaceContainerLowest'
    'context.colors.surfaceContainerLow' = 'AppColors.surfaceContainerLow'
    'context.colors.outlineVariant' = 'AppColors.outlineVariant'
    'context.colors.sidebarBg' = 'AppColors.sidebarBg'
    'context.colors.bootButtonBg' = 'AppColors.bootButtonBg'
    'context.colors.inputBorderLight' = 'AppColors.inputBorderLight'
    'context.colors.warmBackground' = 'AppColors.warmBackground'
}

$fixedUndefined = 0
foreach ($filePath in $undefinedLines.Keys) {
    if (-not (Test-Path $filePath)) { continue }
    $lines = [System.IO.File]::ReadAllLines($filePath)
    $changed = $false
    foreach ($lineNum in $undefinedLines[$filePath]) {
        $idx = $lineNum - 1
        if ($idx -ge 0 -and $idx -lt $lines.Count -and $lines[$idx] -match 'context\.colors') {
            foreach ($key in $reverseMap.Keys) {
                $lines[$idx] = $lines[$idx].Replace($key, $reverseMap[$key])
            }
            $changed = $true
        }
    }
    if ($changed) {
        [System.IO.File]::WriteAllLines($filePath, $lines)
        $fixedUndefined++
        Write-Host "Reverted undefined context in: $filePath"
    }
}
Write-Host "Fixed $fixedUndefined files with undefined context."

# --- Part 2: Fix remaining invalid_constant errors ---
# More aggressive: find ALL const keywords on lines BEFORE context.colors usage
$allFiles = Get-ChildItem -Path $targetDir -Filter "*.dart" -Recurse
$fixedConst = 0

foreach ($file in $allFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($content -notmatch 'context\.colors') { continue }
    $original = $content
    
    $lines = $content -split "`n"
    
    # Track bracket depth to find parent const declarations
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'context\.colors') {
            # Remove any remaining const on this line
            $lines[$i] = $lines[$i] -replace '\bconst\s+', ''
            
            # Look backwards to find parent const declarations
            $depth = 0
            for ($j = $i; $j -ge [Math]::Max(0, $i - 30); $j--) {
                $closeParen = ($lines[$j].ToCharArray() | Where-Object { $_ -eq ')' }).Count
                $openParen = ($lines[$j].ToCharArray() | Where-Object { $_ -eq '(' }).Count
                $depth += $closeParen - $openParen
                if ($depth -gt 0 -and $lines[$j] -match '^\s*const\s+\w') {
                    $lines[$j] = $lines[$j] -replace '\bconst\s+', ''
                    break
                }
                if ($depth -gt 0 -and $lines[$j] -match ':\s*const\s+\w') {
                    $lines[$j] = $lines[$j] -replace ':\s*const\s+', ': '
                    break
                }
            }
        }
    }
    
    $content = $lines -join "`n"
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $fixedConst++
        Write-Host "Fixed const in: $($file.FullName)"
    }
}
Write-Host "Fixed const in $fixedConst files."
Write-Host "`nPhase 2 complete!"
