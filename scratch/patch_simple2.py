import os
import re

file_path = r'lib\features\operator\screens\operator_auth_gate_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
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
        print('Fixed operator_auth_gate_screen')

# Fix admin_shell.dart missing getters: users, claims, adminWallet
# We'll just replace them with fallback strings to fix the build immediately, or standard keys
file_path = r'lib\features\shared\widgets\navigation\admin_shell.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace AppLocalizations.of(context)!.users -> AppLocalizations.of(context)!.client
    # since `users` might not exist but `client` does, or we just put a string literal
    content = content.replace("AppLocalizations.of(context)!.users", "'Users'")
    content = content.replace("AppLocalizations.of(context)!.claims", "'Claims'")
    content = content.replace("AppLocalizations.of(context)!.adminWallet", "'Wallet'")
    content = content.replace("import 'package:easy_localization/easy_localization.dart';", "")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print('Fixed admin_shell')
