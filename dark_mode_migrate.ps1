
# Dark Mode Migration Script
# Replaces hardcoded AppColors.xxx with context.colors.xxx in all screen files

$targetDir = "d:\tameenidz\lib"
$importLine = "import 'package:tameenidz/core/theme/app_colors_extension.dart';"

# Files to skip (theme definition files)
$skipPatterns = @('app_colors.dart', 'app_colors_extension.dart', 'app_theme.dart', 'premium_tokens.dart')

$files = Get-ChildItem -Path $targetDir -Filter "*.dart" -Recurse | Where-Object {
    $name = $_.Name
    -not ($skipPatterns | Where-Object { $name -eq $_ })
}

$changedCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content

    # Only process files that have target color references
    if ($content -notmatch 'AppColors\.(beigeBg|darkText|beigeCard|onSurface[^D]|warmDivider|beigeDeep|slate[1-7]|offWhite[^C]|background[^D]|surface[^CD]|softSlate|sidebarBg|bootButtonBg|inputBorderLight|warmBackground|textMuted|textSecondary|subText|textPrimary|textDark|ctaText|outlineVariant)') {
        continue
    }

    # Add import if missing
    if ($content -notmatch 'app_colors_extension\.dart') {
        $content = $content -replace "(import 'package:tameenidz/core/theme/app_colors\.dart';)", "`$1`n$importLine"
    }

    # Replace colors (order matters - longer names first to avoid partial matches)
    $content = $content -replace 'AppColors\.surfaceContainerLowest', 'context.colors.surfaceContainerLowest'
    $content = $content -replace 'AppColors\.surfaceContainerHigh\b', 'context.colors.surfaceContainerHigh'
    $content = $content -replace 'AppColors\.surfaceContainerLow\b', 'context.colors.surfaceContainerLow'
    $content = $content -replace 'AppColors\.surfaceContainer\b(?!Dark|High|Low)', 'context.colors.surfaceContainer'
    $content = $content -replace 'AppColors\.backgroundBeige', 'context.colors.beigeBg'
    $content = $content -replace 'AppColors\.surfaceBeige', 'context.colors.beigeCard'
    $content = $content -replace 'AppColors\.onSurfaceVariant\b(?!Dark)', 'context.colors.onSurfaceVariant'
    $content = $content -replace 'AppColors\.onSurface\b(?!Variant|Dark)', 'context.colors.onSurface'
    $content = $content -replace 'AppColors\.offWhite\b(?!Container)', 'context.colors.offWhite'
    $content = $content -replace 'AppColors\.outlineVariant', 'context.colors.outlineVariant'
    $content = $content -replace 'AppColors\.inputBorderLight', 'context.colors.inputBorderLight'
    $content = $content -replace 'AppColors\.warmBackground', 'context.colors.warmBackground'
    $content = $content -replace 'AppColors\.warmDivider', 'context.colors.warmDivider'
    $content = $content -replace 'AppColors\.bootButtonBg', 'context.colors.bootButtonBg'
    $content = $content -replace 'AppColors\.textSecondary', 'context.colors.slate500'
    $content = $content -replace 'AppColors\.textPrimary', 'context.colors.darkText'
    $content = $content -replace 'AppColors\.textMuted', 'context.colors.slate500'
    $content = $content -replace 'AppColors\.background\b(?!Beige|Dark)', 'context.colors.background'
    $content = $content -replace 'AppColors\.surface\b(?!Beige|Dark|Card|Container)', 'context.colors.surface'
    $content = $content -replace 'AppColors\.beigeBg', 'context.colors.beigeBg'
    $content = $content -replace 'AppColors\.beigeCard', 'context.colors.beigeCard'
    $content = $content -replace 'AppColors\.beigeDeep', 'context.colors.beigeDeep'
    $content = $content -replace 'AppColors\.darkText', 'context.colors.darkText'
    $content = $content -replace 'AppColors\.textDark', 'context.colors.darkText'
    $content = $content -replace 'AppColors\.sidebarBg', 'context.colors.sidebarBg'
    $content = $content -replace 'AppColors\.softSlate', 'context.colors.softSlate'
    $content = $content -replace 'AppColors\.slate100', 'context.colors.slate100'
    $content = $content -replace 'AppColors\.slate200', 'context.colors.slate200'
    $content = $content -replace 'AppColors\.slate300', 'context.colors.slate300'
    $content = $content -replace 'AppColors\.slate400', 'context.colors.slate400'
    $content = $content -replace 'AppColors\.slate500', 'context.colors.slate500'
    $content = $content -replace 'AppColors\.slate700', 'context.colors.slate700'
    $content = $content -replace 'AppColors\.subText', 'context.colors.slate500'
    $content = $content -replace 'AppColors\.ctaText', 'context.colors.darkText'

    # Remove 'const' on lines that now contain 'context.colors'
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'context\.colors') {
            $lines[$i] = $lines[$i] -replace '\bconst\s+(?=TextStyle|BoxDecoration|Icon\(|EdgeInsets|Border\b|BorderSide)', ''
        }
    }
    $content = $lines -join "`n"

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $changedCount++
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nDone! Updated $changedCount files."
