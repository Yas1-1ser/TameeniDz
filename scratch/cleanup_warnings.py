import os
import re

# We will clean up the warnings mentioned in the analyzer output.
# 1. lib/features/client/auth/registration/steps/step1_personal_info.dart (line 8: unused_import colors_extension)
# 2. lib/features/client/auth/registration/steps/step2_password_setup.dart (lines 5, 9: unused)
# 3. lib/features/client/auth/registration/steps/step3_document_upload.dart (lines 9, 11: unused)
# 4. lib/features/onboarding/screens/onboarding_screen.dart (line 10: easy_localization, line 11: duplicate app_colors)
# 5. lib/features/operator/auth/operator_register_screen.dart (lines 6, 8)
# 6. lib/features/operator/screens/operator_auth_gate_screen.dart (line 8: duplicate app_colors)
# 7. lib/features/shared/widgets/app_sidebar.dart (line 5: colors_extension)
# 8. lib/features/shared/widgets/navigation/admin_shell.dart (line 9: easy_localization)

def remove_line_from_file(file_path, line_num_1indexed):
    if not os.path.exists(file_path): return
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    if 0 < line_num_1indexed <= len(lines):
        # Just empty the line or delete it
        lines[line_num_1indexed - 1] = '// Removed unused import\n'
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(''.join(lines))
        print(f"Removed line {line_num_1indexed} from {file_path}")

# Since the line numbers in standard flutter analyze output might change slightly, we can search and replace exact lines.
def replace_exact_lines(file_path, target_list):
    if not os.path.exists(file_path): return
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    for target in target_list:
        content = content.replace(target, '')
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Cleaned imports in {file_path}")

replace_exact_lines(r'lib\features\client\auth\registration\steps\step1_personal_info.dart', [
    "import '../../../../../core/theme/app_colors_extension.dart';",
])
replace_exact_lines(r'lib\features\client\auth\registration\steps\step2_password_setup.dart', [
    "import 'package:flutter_animate/flutter_animate.dart';",
    "import '../../../../../core/theme/app_colors_extension.dart';",
])
replace_exact_lines(r'lib\features\client\auth\registration\steps\step3_document_upload.dart', [
    "import 'package:flutter_animate/flutter_animate.dart';",
    "import '../../../../../core/theme/app_colors_extension.dart';",
])
replace_exact_lines(r'lib\features\onboarding\screens\onboarding_screen.dart', [
    "import 'package:easy_localization/easy_localization.dart' hide TextDirection;",
    "import 'package:tameenidz/core/theme/app_colors.dart';",
])
replace_exact_lines(r'lib\features\operator\auth\operator_register_screen.dart', [
    "import 'package:flutter_animate/flutter_animate.dart';",
    "import '../../../core/theme/app_colors_extension.dart';",
])
replace_exact_lines(r'lib\features\operator\screens\operator_auth_gate_screen.dart', [
    "import 'package:tameenidz/core/theme/app_colors.dart';",
])
replace_exact_lines(r'lib\features\shared\widgets\app_sidebar.dart', [
    "import '../../../core/theme/app_colors_extension.dart';",
])
replace_exact_lines(r'lib\features\shared\widgets\navigation\admin_shell.dart', [
    "import 'package:easy_localization/easy_localization.dart';",
])
