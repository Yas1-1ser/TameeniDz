import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;
  final Map<String, String> roles; // roleKey -> label

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: roles.entries.map((entry) {
        final isSelected = selectedRole == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onRoleChanged(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.goldAccent : context.colors.offWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.goldAccent : context.colors.outlineVariant,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.goldAccent.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? context.colors.offWhite : context.colors.slate500,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
