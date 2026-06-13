import os
import re

def to_camel_case(snake_str):
    components = snake_str.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])

lib_dir = r'd:\tameenidz\lib'

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()

            original = content

            # 1. Replace easy_localization import
            content = re.sub(
                r"import\s+'package:easy_localization/easy_localization\.dart';\n?", 
                "import 'package:tameenidz/generated/l10n/app_localizations.dart';\n", 
                content
            )

            # 2. Replace context.locale.languageCode and context.locale
            content = content.replace("context.locale.languageCode", "Localizations.localeOf(context).languageCode")
            content = content.replace("context.locale", "Localizations.localeOf(context)")

            # 3. Handle simple .tr() calls: 'key'.tr() or "key".tr()
            def replacer(match):
                key = match.group(1)
                camel_key = to_camel_case(key)
                return f"AppLocalizations.of(context)!.{camel_key}"

            content = re.sub(r"['\"]([a-zA-Z0-9_]+)['\"]\s*\.tr\(\)", replacer, content)

            # 4. Handle .tr(namedArgs: {...})
            # This is hard to do perfectly via regex because namedArgs are dynamic,
            # but we can try to flag them or replace them with a generic method call.
            def replacer_args(match):
                key = match.group(1)
                camel_key = to_camel_case(key)
                args = match.group(2)
                # Just print a warning to console and do a best effort replacement.
                print(f"WARNING: File {filepath} has .tr() with args: {key}.tr({args})")
                return f"AppLocalizations.of(context)!.{camel_key} /* TODO: fix args {args} */"

            content = re.sub(r"['\"]([a-zA-Z0-9_]+)['\"]\s*\.tr\((.*?)\)", replacer_args, content)

            # Fix specific file: sos_screen.dart
            if f == 'sos_screen.dart':
                content = content.replace("String _selectedWilaya = AppLocalizations.of(context)!.all;", "String _selectedWilaya = '';")
                content = content.replace("String _selectedWilaya = 'all'.tr();", "String _selectedWilaya = '';")
                if "if (_selectedWilaya.isEmpty) _selectedWilaya = AppLocalizations.of(context)!.all;" not in content:
                    content = content.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    if (_selectedWilaya.isEmpty) _selectedWilaya = AppLocalizations.of(context)!.all;")

            if content != original:
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f"Updated {f}")
