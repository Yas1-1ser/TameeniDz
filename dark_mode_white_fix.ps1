
# Fix Colors.white card backgrounds -> context.colors.surface
# Only targets BoxDecoration color, Container color, backgroundColor on cards/chips
# Does NOT touch foregroundColor, TextStyle color, Icon color, CircularProgressIndicator

$targetDir = "d:\tameenidz\lib"
$skipPatterns = @('app_colors.dart', 'app_colors_extension.dart', 'app_theme.dart', 'premium_tokens.dart')
$importLine = "import 'package:tameenidz/core/theme/app_colors_extension.dart';"

$files = Get-ChildItem -Path $targetDir -Filter "*.dart" -Recurse | Where-Object {
    $name = $_.Name
    -not ($skipPatterns | Where-Object { $name -eq $_ })
}

$changedCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content
    
    if ($content -notmatch 'Colors\.white') { continue }
    
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Skip lines with foregroundColor, TextStyle, Icon, CircularProgressIndicator, style:
        if ($line -match 'foregroundColor|TextStyle|Icon\(|CircularProgressIndicator|style:|strokeWidth') { continue }
        
        # Replace Colors.white in BoxDecoration color, Container color, backgroundColor (for cards)
        if ($line -match '^\s*(color|fillColor|backgroundColor):\s*(const\s+)?Colors\.white\b') {
            $lines[$i] = $line -replace 'const\s+Colors\.white', 'context.colors.surface'
            $lines[$i] = $lines[$i] -replace 'Colors\.white', 'context.colors.surface'
        }
        
        # Replace Colors.white inside BoxDecoration(color: Colors.white, ...)
        if ($line -match 'BoxDecoration\(.*color:\s*(const\s+)?Colors\.white') {
            $lines[$i] = $line -replace 'const\s+Colors\.white', 'context.colors.surface'
            $lines[$i] = $lines[$i] -replace 'Colors\.white', 'context.colors.surface'
            # Remove const from BoxDecoration
            $lines[$i] = $lines[$i] -replace 'const\s+BoxDecoration', 'BoxDecoration'
        }
    }
    $content = $lines -join "`n"
    
    # Add import if we made changes and it's missing
    if ($content -ne $original -and $content -notmatch 'app_colors_extension\.dart') {
        if ($content -match "import 'package:flutter/material\.dart';") {
            $content = $content -replace "(import 'package:flutter/material\.dart';)", "`$1`n$importLine"
        }
    }
    
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $changedCount++
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nDone! Updated $changedCount files for Colors.white card backgrounds."
