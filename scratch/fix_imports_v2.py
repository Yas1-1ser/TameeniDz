import os

def restore_colors_import(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if "import 'package:tameenidz/core/theme/app_colors.dart';" not in content:
            content = "import 'package:tameenidz/core/theme/app_colors.dart';\n" + content
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Restored import in {file_path}')

restore_colors_import(r'lib\features\operator\screens\operator_auth_gate_screen.dart')
restore_colors_import(r'lib\features\onboarding\screens\onboarding_screen.dart')
