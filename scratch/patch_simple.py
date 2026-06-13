import os
import re

# Fix email verification modal
file_path = r'lib\features\shared\widgets\email_verification_modal.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We must convert snake_case keys back to camelCase for AppLocalizations
    def to_camel_case(match):
        snake_str = match.group(1)
        components = snake_str.split('_')
        camel = components[0] + ''.join(x.title() for x in components[1:])
        return f"AppLocalizations.of(context)!.{camel}"

    content = re.sub(r"tr\(['\"]([^'\"]+)['\"]\)", to_camel_case, content)
    content = re.sub(r"['\"]([^'\"]+)['\"]\s*\.tr\(\)", to_camel_case, content)
    content = re.sub(r"([a-zA-Z0-9_]+)\.tr\(\)", r"\1", content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print('Fixed email_verification_modal')

# Fix smart_quote_form
file_path = r'lib\features\shared\widgets\smart_quote_form.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    if "import 'package:intl/intl.dart';" not in content:
        content = "import 'package:intl/intl.dart';\n" + content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
            print('Fixed smart_quote_form')
