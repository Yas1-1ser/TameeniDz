import os
import re

with open('analyze.txt', 'r', encoding='utf-16') as f:
    lines = f.readlines()

files_to_fix = {}
for line in lines:
    if 'lib\\' in line:
        parts = line.split(' - ')
        if len(parts) >= 3:
            file_part = parts[-2]
            file_path = file_part.split(':')[0].strip()
            error_msg = parts[0].strip()
            if file_path not in files_to_fix:
                files_to_fix[file_path] = []
            files_to_fix[file_path].append(error_msg)

for file, errors in files_to_fix.items():
    if not os.path.exists(file): continue
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Fix missing AppLocalizations import
    if any("Undefined name 'AppLocalizations'" in e for e in errors) or any("Undefined name 'l10n'" in e for e in errors):
        if "import 'package:tameenidz/generated/l10n/app_localizations.dart';" not in content:
            # add after the first import block
            content = re.sub(r"(import\s+.*?;)(\n\s*\n|\n(?![import]))", r"\1\nimport 'package:tameenidz/generated/l10n/app_localizations.dart';\2", content, count=1)
            # fallback if it didn't replace
            if "import 'package:tameenidz/generated/l10n/app_localizations.dart';" not in content:
                content = "import 'package:tameenidz/generated/l10n/app_localizations.dart';\n" + content

    # Fix missing DateFormat import
    if any("The method 'DateFormat' isn't defined" in e for e in errors):
        if "import 'package:intl/intl.dart';" not in content:
            content = "import 'package:intl/intl.dart';\n" + content

    # Fix missing context
    if any("Undefined name 'context'" in e for e in errors) and file.endswith('renewal_alert_banner.dart'):
        content = content.replace("_config(int daysRemaining)", "_config(BuildContext context, int daysRemaining)")
        content = content.replace("_config(daysRemaining)", "_config(context, daysRemaining)")

    # Fix StatusBadge
    if file.endswith('status_badge.dart'):
        content = re.sub(r"status\.tr\(\)", "status.name.toUpperCase()", content)
        content = re.sub(r"['\"]completed['\"]\s*\.tr\(\)", "AppLocalizations.of(context)!.completed", content)
        content = re.sub(r"['\"]active['\"]\s*\.tr\(\)", "AppLocalizations.of(context)!.active", content)
        content = re.sub(r"['\"]pending['\"]\s*\.tr\(\)", "AppLocalizations.of(context)!.pending", content)
        content = re.sub(r"['\"]rejected['\"]\s*\.tr\(\)", "AppLocalizations.of(context)!.rejected", content)
        content = re.sub(r"['\"]modification_requested['\"]\s*\.tr\(\)", "AppLocalizations.of(context)!.modificationRequested", content)
        
    if file.endswith('email_verification_modal.dart') or file.endswith('operator_auth_gate_screen.dart'):
        # Fix dynamic string tr()
        content = re.sub(r"([a-zA-Z0-9_]+)\.tr\(\)", r"\1.toString()", content)

    if content != original:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Fixed {file}')
