import os

file_path = r'lib\features\operator\screens\operator_auth_gate_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    if "import 'package:tameenidz/core/theme/app_colors.dart';" not in content:
        content = "import 'package:tameenidz/core/theme/app_colors.dart';\n" + content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print('Restored import in operator_auth_gate_screen')
