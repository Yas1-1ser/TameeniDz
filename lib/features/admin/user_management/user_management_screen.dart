import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/features/shared/domain/models/user_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'user_providers.dart';
import 'widgets/user_filters.dart';
import 'widgets/user_table.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final usersAsync = ref.watch(usersStreamProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0E8),
        appBar: buildAdminAppBar(
          context,
          l10n.userManagement,
          actions: [
            _buildHeaderButton(context, isMobile, l10n),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: adminBottomNav(context, 3, l10n),
        body: usersAsync.when(
          data: (users) {
            final clients = users.where((u) => u.role == 'client').toList();
            final employees =
                users
                    .where((u) => u.role == 'employee' || u.role == 'operator')
                    .toList();

            return Column(
              children: [
                Container(
                  color: context.colors.surface,
                  child: TabBar(
                    labelColor: const Color(0xFF2D1F0E),
                    unselectedLabelColor: const Color(0xFF8B7355),
                    indicatorColor: const Color(0xFFC9A96E),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(text: '${l10n.clientRoleLabel} (${clients.length})'),
                      Tab(
                        text: '${l10n.operatorRoleLabel} (${employees.length})',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      UserTable(
                        users: clients,
                        role: 'client',
                        onView:
                            (u) => UserDialogHelper.showUserDetails(
                              context,
                              ref,
                              u,
                              l10n,
                            ),
                        onEdit:
                            (u) => UserDialogHelper.showEditUserDialog(
                              context,
                              ref,
                              u,
                              l10n,
                            ),
                        onDelete:
                            (u) => UserDialogHelper.showDeleteConfirmation(
                              context,
                              ref,
                              u,
                              l10n,
                            ),
                      ),
                      UserTable(
                        users: employees,
                        role: 'employee',
                        onView:
                            (u) => UserDialogHelper.showUserDetails(
                              context,
                              ref,
                              u,
                              l10n,
                            ),
                        onEdit:
                            (u) => UserDialogHelper.showEditUserDialog(
                              context,
                              ref,
                              u,
                              l10n,
                            ),
                        onDelete:
                            (u) => UserDialogHelper.showDeleteConfirmation(
                              context,
                              ref,
                              u,
                              l10n,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
              ),
          error:
              (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFA03030),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.unexpectedError}: $err',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(usersStreamProvider),
                      child: Text(
                        l10n.retry,
                        style: const TextStyle(
                          color: Color(0xFFC9A96E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(
    BuildContext context,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    if (isMobile) {
      return IconButton(
        onPressed: () => UserDialogHelper.showAddUserDialog(context, l10n),
        icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFC9A96E)),
        tooltip: l10n.addUser,
      );
    }
    return ElevatedButton.icon(
      onPressed: () => UserDialogHelper.showAddUserDialog(context, l10n),
      icon: const Icon(Icons.person_add_alt_1, size: 18),
      label: Text(
        l10n.addUser,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC9A96E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}
