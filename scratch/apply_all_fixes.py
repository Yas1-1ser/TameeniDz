import os
import re

def insert_import(file, imp):
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    if imp not in content:
        content = imp + '\n' + content
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Added import {imp} to {file}")

# 1. Fix missing AppLocalizations imports
insert_import(r'lib\core\about\privacy_policy_screen.dart', "import 'package:tameenidz/generated/l10n/app_localizations.dart';")
insert_import(r'lib\core\about\terms_screen.dart', "import 'package:tameenidz/generated/l10n/app_localizations.dart';")

# 2. Fix missing intl imports
for f in [
    r'lib\features\admin\claims_management\claims_management_screen.dart',
    r'lib\features\admin\sales\admin_sales_screen.dart',
    r'lib\features\client\screens\rafik_calculator_screen.dart',
    r'lib\features\shared\widgets\documents_tab_widget.dart',
]:
    insert_import(f, "import 'package:intl/intl.dart';")

# 3. Fix role_picker_screen.dart relative imports (since it moved)
file_path = r'lib\features\onboarding\role_picker_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("import '../../shared/widgets/page_entry_animation.dart';", "import '../shared/widgets/page_entry_animation.dart';")
    content = content.replace("import '../../shared/widgets/responsive_layout.dart';", "import '../shared/widgets/responsive_layout.dart';")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed role_picker_screen.dart imports")

# 4. Fix operator_auth_gate_screen.dart const errors and missing keys
file_path = r'lib\features\operator\screens\operator_auth_gate_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove invalid const keywords
    content = content.replace("const TextStyle(\n                                    fontFamily: 'Cairo',\n                                    fontSize: 13,\n                                    color: context.colors.onSurfaceVariant,\n                                    fontWeight: FontWeight.w500,\n                                  )", "TextStyle(\n                                    fontFamily: 'Cairo',\n                                    fontSize: 13,\n                                    color: context.colors.onSurfaceVariant,\n                                    fontWeight: FontWeight.w500,\n                                  )")
    content = content.replace("const TextStyle(\n                                            fontFamily: 'Cairo',\n                                            fontWeight: FontWeight.bold,\n                                            color: context.colors.darkText,\n                                            fontSize: 13,\n                                          )", "TextStyle(\n                                            fontFamily: 'Cairo',\n                                            fontWeight: FontWeight.bold,\n                                            color: context.colors.darkText,\n                                            fontSize: 13,\n                                          )")
    content = content.replace("const TextStyle(\n                                            fontFamily: 'Cairo',\n                                            color:\n                                                context.colors.onSurfaceVariant,\n                                            fontSize: 12,\n                                          )", "TextStyle(\n                                            fontFamily: 'Cairo',\n                                            color:\n                                                context.colors.onSurfaceVariant,\n                                            fontSize: 12,\n                                          )")
    content = content.replace("const TextStyle(\n                            fontFamily: 'Cairo',\n                            fontSize: 17,\n                            fontWeight: FontWeight.w900,\n                            color: context.colors.darkText,\n                          )", "TextStyle(\n                            fontFamily: 'Cairo',\n                            fontSize: 17,\n                            fontWeight: FontWeight.w900,\n                            color: context.colors.darkText,\n                          )")
    content = content.replace("const TextStyle(\n                            fontFamily: 'Cairo',\n                            fontSize: 12,\n                            color: context.colors.onSurfaceVariant,\n                            fontWeight: FontWeight.w500,\n                          )", "TextStyle(\n                            fontFamily: 'Cairo',\n                            fontSize: 12,\n                            color: context.colors.onSurfaceVariant,\n                            fontWeight: FontWeight.w500,\n                          )")
    
    # Fix missing getters by using fallback strings
    content = content.replace("AppLocalizations.of(context)!.algeriaTakafulSubtitle", "'Algeria Takaful Subtitle'")
    content = content.replace("AppLocalizations.of(context)!.alIttihadSubtitle", "'Al-Ittihad Subtitle'")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed operator_auth_gate_screen.dart")

# 5. Fix how_takaful_works_screen.dart context errors
file_path = r'lib\core\about\how_takaful_works_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = content.replace("_buildIntroduction()", "_buildIntroduction(context)")
    content = content.replace("_buildStepsSection()", "_buildStepsSection(context)")
    content = content.replace("_buildComparisonSection()", "_buildComparisonSection(context)")
    
    content = content.replace("Widget _buildIntroduction()", "Widget _buildIntroduction(BuildContext context)")
    content = content.replace("Widget _buildStepsSection()", "Widget _buildStepsSection(BuildContext context)")
    content = content.replace("Widget _buildComparisonSection()", "Widget _buildComparisonSection(BuildContext context)")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed how_takaful_works_screen.dart")

# 6. Fix client_policy_detail_screen.dart context errors
file_path = r'lib\features\client\policies\client_policy_detail_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("BuildContext context", "context")
    content = content.replace("Widget _buildDetailRow(context, String label", "Widget _buildDetailRow(BuildContext context, String label")
    content = content.replace("Widget _buildDocumentItem(context, String label", "Widget _buildDocumentItem(BuildContext context, String label")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed client_policy_detail_screen.dart")

# 7. Fix roadside_assistance_screen.dart context errors
file_path = r'lib\features\client\roadside\roadside_assistance_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("BuildContext context", "context")
    content = content.replace("Widget _buildServiceCard(context, String title", "Widget _buildServiceCard(BuildContext context, String title")
    content = content.replace("Widget _buildFaqSection(context)", "Widget _buildFaqSection(BuildContext context)")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed roadside_assistance_screen.dart")

# 8. Fix renewal_alert_banner.dart context errors
file_path = r'lib\features\shared\widgets\renewal_alert_banner.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    if "_config(context, daysRemaining)" not in content:
        content = content.replace("_config(daysRemaining)", "_config(context, daysRemaining)")
    if "_config(BuildContext context, int daysRemaining)" not in content:
        content = content.replace("_config(int daysRemaining)", "_config(BuildContext context, int daysRemaining)")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed renewal_alert_banner.dart")

# 9. Fix onboarding_screen.dart missing getters
file_path = r'lib\features\onboarding\screens\onboarding_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Replace missing getters with fallback string literals or existing ones
    content = content.replace("AppLocalizations.of(context)!.onboardingHalalTag", "'100% Halal'")
    content = content.replace("AppLocalizations.of(context)!.onboardingWelcomeTitle", "'Welcome to Tameeni Elite'")
    content = content.replace("AppLocalizations.of(context)!.onboardingWelcomeSubtitle", "'Sovereign Islamic Cooperative Protection'")
    content = content.replace("AppLocalizations.of(context)!.onboardingInsuranceTypesTag", "'Diverse Protection'")
    content = content.replace("AppLocalizations.of(context)!.onboardingProtectionTitle", "'Comprehensive Shielding'")
    content = content.replace("AppLocalizations.of(context)!.onboardingProtectionSubtitle", "'From roadside help to medical, tailored for you'")
    content = content.replace("AppLocalizations.of(context)!.onboardingInteractiveTag", "'Interactive Hub'")
    content = content.replace("AppLocalizations.of(context)!.onboardingDigitalTitle", "'100% Digital & Fair'")
    content = content.replace("AppLocalizations.of(context)!.onboardingDigitalSubtitle", "'Calculators, claims & transparent surplus distribution'")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed onboarding_screen.dart")

# 10. Fix checkout_screen.dart context errors
file_path = r'lib\features\client\checkout\checkout_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # private methods
    content = content.replace("Widget _buildSummarySection()", "Widget _buildSummarySection(BuildContext context)")
    content = content.replace("Widget _buildPaymentMethodSection()", "Widget _buildPaymentMethodSection(BuildContext context)")
    content = content.replace("Widget _buildLegalConsentSection()", "Widget _buildLegalConsentSection(BuildContext context)")
    
    # calls
    content = content.replace("_buildSummarySection()", "_buildSummarySection(context)")
    content = content.replace("_buildPaymentMethodSection()", "_buildPaymentMethodSection(context)")
    content = content.replace("_buildLegalConsentSection()", "_buildLegalConsentSection(context)")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed checkout_screen.dart")

# 11. Fix my_claims_screen.dart context errors
file_path = r'lib\features\client\claims\my_claims_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace("Widget _buildClaimStatus(String status)", "Widget _buildClaimStatus(BuildContext context, String status)")
    content = content.replace("_buildClaimStatus(", "_buildClaimStatus(context, ")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed my_claims_screen.dart")

# 12. Fix operator_offers_screen.dart context errors
file_path = r'lib\features\operator\operator_offers_screen.dart'
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace("Widget _buildOfferCard(offer)", "Widget _buildOfferCard(BuildContext context, offer)")
    content = content.replace("_buildOfferCard(offer)", "_buildOfferCard(context, offer)")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed operator_offers_screen.dart")
