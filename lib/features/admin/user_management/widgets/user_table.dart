import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../shared/domain/models/user_model.dart';

class UserTable extends StatelessWidget {
  final List<UserModel> users;
  final String role;
  final void Function(UserModel) onView;
  final void Function(UserModel) onEdit;
  final void Function(UserModel) onDelete;

  const UserTable({
    super.key,
    required this.users,
    required this.role,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (users.isEmpty) {
      return Center(child: Text(l10n.noUsersFound, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF8B7355))));
    }

    final isClient = role == 'client';
    final isEmployee = role == 'employee' || role == 'operator';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5DDD0),
            width: 0.5,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFC9A96E).withValues(alpha: 0.05),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    l10n.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.emailLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                  ),
                ),
                if (isClient) ...[
                  DataColumn(
                    label: Text(
                      l10n.phoneLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.documents,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                    ),
                  ),
                ],
                if (isEmployee)
                  DataColumn(
                    label: Text(
                      l10n.operator,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                    ),
                  ),
                DataColumn(
                  label: Text(
                    l10n.joinedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.actions,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                  ),
                ),
              ],
              rows: users
                  .map(
                    (UserModel u) => DataRow(
                      cells: [
                        DataCell(Text(u.fullName, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2D1F0E)))),
                        DataCell(Text(u.email, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2D1F0E)))),
                        if (isClient) ...[
                          DataCell(Text(u.phone ?? '—', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2D1F0E)))),
                          DataCell(_buildStatusBadge(u, l10n)),
                        ],
                        if (isEmployee) DataCell(Text(u.operatorId ?? '—', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2D1F0E)))),
                        DataCell(
                          Text(
                            DateFormat('yyyy-MM-dd').format(u.createdAt),
                            style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2D1F0E)),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 20,
                                  color: Color(0xFFC9A96E),
                                ),
                                onPressed: () => onView(u),
                                tooltip: l10n.viewDetails,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Color(0xFF8B7355),
                                ),
                                onPressed: () => onEdit(u),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Color(0xFFA03030),
                                ),
                                onPressed: () => onDelete(u),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(UserModel user, AppLocalizations l10n) {
    if (!user.documentsSubmitted) {
      return _badge(l10n.noDocsAttached, Colors.grey);
    }

    switch (user.documentStatus) {
      case 'approved':
        return _badge(l10n.accepted, AppColors.primaryGreen);
      case 'rejected':
        return _badge(l10n.rejected, AppColors.error);
      case 'pending':
      default:
        return _badge(l10n.pendingState, Colors.orange);
    }
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class UserDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const UserDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B7355),
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D1F0E), fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}
