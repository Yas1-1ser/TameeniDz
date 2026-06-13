import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/data/plan_repository.dart';

class AdminAddPlanScreen extends ConsumerStatefulWidget {
  const AdminAddPlanScreen({super.key});

  @override
  ConsumerState<AdminAddPlanScreen> createState() => _AdminAddPlanScreenState();
}

class _AdminAddPlanScreenState extends ConsumerState<AdminAddPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _priceController = TextEditingController();
  final _descArController = TextEditingController();
  final _coverageController = TextEditingController();
  final _codeController = TextEditingController();
  
  String _selectedOperator = 'algeria_takaful';
  String _selectedIcon = 'shield';
  bool _isBestValue = false;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _operators = [
    {'id': 'algeria_takaful', 'name': 'Algerie Takaful'},
    {'id': 'al_ittihad', 'name': 'Al-Ittihad'},
  ];

  final List<Map<String, dynamic>> _icons = [
    {'id': 'car', 'icon': Icons.directions_car_rounded, 'label': 'Car (Rafik)'},
    {'id': 'gavel', 'icon': Icons.gavel_rounded, 'label': 'Professional'},
    {'id': 'store', 'icon': Icons.store_rounded, 'label': 'Commercial'},
    {'id': 'shipping', 'icon': Icons.local_shipping_rounded, 'label': 'Transport'},
    {'id': 'agriculture', 'icon': Icons.agriculture_rounded, 'label': 'Agricole'},
    {'id': 'home', 'icon': Icons.home_rounded, 'label': 'Home'},
    {'id': 'shield', 'icon': Icons.shield_rounded, 'label': 'General'},
  ];

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _priceController.dispose();
    _descArController.dispose();
    _coverageController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'plan_code': _codeController.text.trim().toUpperCase(),
        'name_ar': _nameArController.text.trim(),
        'name_en': _nameEnController.text.trim(),
        'operator_id': _selectedOperator,
        'premium_amount': double.parse(_priceController.text.trim()),
        'coverage_details': _coverageController.text.trim(),
        'description_ar': _descArController.text.trim(),
        'icon_type': _selectedIcon,
        'is_best_value': _isBestValue,
        'tabarru_rate': 0.1, // Default
        'surplus_rate': 0.9, // Default
        'claims_duration': '48 Hours',
      };

      await ref.read(planRepositoryProvider).addPlan(data);

      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.planSavedSuccessfully, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: colors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: buildAdminAppBar(context, l10n.addNewOffer),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, l10n.professionalInfo),
              const SizedBox(height: 16),
              
              _buildLabel(context, l10n.adminOperatorCompanyLabel),
              _buildOperatorDropdown(context),
              const SizedBox(height: 16),

              _buildLabel(context, l10n.adminPlanCodeLabel),
              TextFormField(
                controller: _codeController,
                decoration: adminFieldDecoration(context, 'CODE', Icons.qr_code_rounded),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel(context, l10n.adminPlanNameArabicLabel),
              TextFormField(
                controller: _nameArController,
                decoration: adminFieldDecoration(context, l10n.adminNameArabicHint, Icons.edit_note_rounded),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel(context, l10n.adminStartingPriceLabel),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: adminFieldDecoration(context, '0.00', Icons.payments_rounded),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(context, l10n.adminDisplayAndStyleSection),
              const SizedBox(height: 16),
              
              _buildLabel(context, l10n.adminIconTypeLabel),
              _buildIconGrid(context),
              const SizedBox(height: 16),

              SwitchListTile(
                title: Text(l10n.isBestValue, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                subtitle: const Text('Show "Best Value" badge', style: TextStyle(fontSize: 12)),
                value: _isBestValue,
                activeColor: colors.goldAccent,
                onChanged: (v) => setState(() => _isBestValue = v),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(context, l10n.description),
              const SizedBox(height: 16),

              _buildLabel(context, l10n.adminShortDescriptionArabicLabel),
              TextFormField(
                controller: _descArController,
                maxLines: 3,
                decoration: adminFieldDecoration(context, l10n.adminPlanDescriptionHint, Icons.description_rounded),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurfaceVariant, fontFamily: 'Cairo')),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.colors;
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: colors.goldAccent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo')),
      ],
    );
  }

  Widget _buildOperatorDropdown(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOperator,
          isExpanded: true,
          dropdownColor: colors.surface,
          items: _operators.map((op) => DropdownMenuItem(
            value: op['id'] as String,
            child: Text(op['name'] as String, style: const TextStyle(fontFamily: 'Cairo')),
          )).toList(),
          onChanged: (v) => setState(() => _selectedOperator = v!),
        ),
      ),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _icons.map((item) {
        final isSelected = _selectedIcon == item['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = item['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? colors.goldAccent : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? colors.goldAccent : colors.outlineVariant),
              boxShadow: isSelected ? [BoxShadow(color: colors.goldAccent.withValues(alpha: 0.3), blurRadius: 8)] : [],
            ),
            child: Column(
              children: [
                Icon(item['icon'] as IconData, color: isSelected ? colors.surface : colors.darkText),
                const SizedBox(height: 4),
                Text(item['id'] as String, style: TextStyle(fontSize: 10, color: isSelected ? colors.surface : colors.onSurfaceVariant)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
