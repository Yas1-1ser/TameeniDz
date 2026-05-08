import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/features/shared/data/user_repository.dart';
import 'package:tameenidz/shared/widgets/responsive_layout.dart';
import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'user_providers.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/widgets/portal_layout.dart';
import '../../shared/domain/models/user_model.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final usersAsync = ref.watch(usersStreamProvider);
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.dashboard, '/admin/dashboard'),
      (Icons.auto_graph_rounded, l10n.commissionsAdmin, '/admin/commission'),
      (Icons.history_edu_rounded, l10n.legalRecord, '/admin/audit'),
      (Icons.manage_accounts_rounded, l10n.userManagement, '/admin/users'),
      (Icons.settings_rounded, l10n.settingsAdmin, '/admin/settings'),
    ];

    final isMobile = ResponsiveLayout.isMobile(context);

    // Build the bottom navigation bar for mobile
    final bottomNavBar = BottomNavigationBar(
      currentIndex: 3, // Users is index 3 in bottom nav
      onTap: (idx) {
        final targetIdx = idx == 3 ? 4 : idx;
        context.go(menuItems[targetIdx].$3);
      },
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(menuItems[0].$1),
          label: menuItems[0].$2,
        ),
        BottomNavigationBarItem(
          icon: Icon(menuItems[1].$1),
          label: menuItems[1].$2,
        ),
        BottomNavigationBarItem(
          icon: Icon(menuItems[2].$1),
          label: menuItems[2].$2,
        ),
        BottomNavigationBarItem(
          icon: Icon(menuItems[4].$1),
          label: menuItems[4].$2,
        ), // Settings
      ],
    );

    return DefaultTabController(
      length: 2,
      child: PortalLayout(
        selectedIndex: 3,
        menuItems: menuItems,
        portalTitle: l10n.userManagement,
        portalSubtitle: l10n.shariaInsurance,
        accentColor: colors.primary,
        showBackButton: false,
        fallbackRoute: '/admin/dashboard',
        bottomNavigationBar: isMobile ? bottomNavBar : null,
        appBarActions: [
          const SizedBox(width: 8),
          isMobile
              ? IconButton(
                onPressed: () => _showAddUserDialog(context, l10n),
                icon: const Icon(
                  Icons.person_add_alt_1,
                  color: AppColors.primaryGreen,
                ),
                tooltip: l10n.addUser,
              )
              : ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context, l10n),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: Text(l10n.addUser),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
        ],
        body: usersAsync.when(
          data: (users) {
            final clients = users.where((u) => u.role == 'client').toList();
            final employees =
                users
                    .where((u) => u.role == 'employee' || u.role == 'operator')
                    .toList();

            return Column(
              children: [
                TabBar(
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.onSurfaceVariant,
                  indicatorColor: colors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: '${l10n.clientRoleLabel} (${clients.length})'),
                    Tab(
                      text: '${l10n.operatorRoleLabel} (${employees.length})',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildUserTable(context, ref, clients, role: 'client'),
                      _buildUserTable(context, ref, employees, role: 'employee'),
                    ],
                  ),
                ),
              ],
            );
          },
          loading:
              () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading users...'),
                  ],
                ),
              ),
          error:
              (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.rejected,
                    ),
                    const SizedBox(height: 16),
                    Text('${l10n.unexpectedError}: $err'),
                    TextButton(
                      onPressed: () => ref.invalidate(usersStreamProvider),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.addUser),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryGreen,
                  ),
                  title: Text(l10n.client),
                  subtitle: Text(l10n.clientRoleSubtitle),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/role/client');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.business_outlined,
                    color: AppColors.subscriberFund,
                  ),
                  title: Text(l10n.operatorRole),
                  subtitle: Text(l10n.operatorRoleSubtitle),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/operator/register');
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          ),
    );
  }

  Widget _buildUserTable(
    BuildContext context,
    WidgetRef ref,
    List<UserModel> users, {
    required String role,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (users.isEmpty) {
      return Center(child: Text(l10n.noUsersFound));
    }

    final isClient = role == 'client';
    final isEmployee = role == 'employee' || role == 'operator';

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16 : 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.primaryGreen.withValues(alpha: 0.04),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    l10n.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.emailLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isClient) ...[
                  DataColumn(
                    label: Text(
                      l10n.phoneLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.ccpLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                if (isEmployee)
                  DataColumn(
                    label: Text(
                      l10n.operator,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                DataColumn(
                  label: Text(
                    l10n.joinedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.actions,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  users
                      .map(
                        (UserModel u) => DataRow(
                          cells: [
                            DataCell(Text(u.fullName)),
                            DataCell(Text(u.email)),
                            if (isClient) ...[
                              DataCell(Text(u.phone ?? '—')),
                              DataCell(Text(u.ccpNumber ?? '—')),
                            ],
                            if (isEmployee) DataCell(Text(u.operatorId ?? '—')),
                            DataCell(
                              Text(
                                DateFormat('yyyy-MM-dd').format(u.createdAt),
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
                                      color: AppColors.primaryGreen,
                                    ),
                                    onPressed:
                                        () =>
                                            _showUserDetails(context, u, l10n),
                                    tooltip: l10n.viewDetails,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: AppColors.goldAccent,
                                    ),
                                    onPressed:
                                        () => _showEditUserDialog(
                                          context,
                                          ref,
                                          u,
                                          l10n,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: AppColors.rejected,
                                    ),
                                    onPressed:
                                        () => _showDeleteConfirmation(
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
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteUser),
            content: Text(l10n.deleteUserConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(userRepositoryProvider).deleteUser(user.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User ${user.fullName} deleted'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting user: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rejected,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AppLocalizations l10n,
  ) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone);
    final ccpCtrl = TextEditingController(text: user.ccpNumber);
    final roleCtrl = TextEditingController(text: user.role);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${l10n.editUser} ${user.fullName}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l10n.fullName),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: l10n.phoneLabel),
                  ),
                  if (user.role == 'client') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: ccpCtrl,
                      decoration: InputDecoration(labelText: l10n.ccpLabel),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: user.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'client', child: Text('Client')),
                      DropdownMenuItem(
                        value: 'operator',
                        child: Text('Operator'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (v) => roleCtrl.text = v ?? user.role,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final updatedUser = UserModel(
                      id: user.id,
                      fullName: nameCtrl.text,
                      email:
                          user.email, // Email usually stays the same for Auth
                      phone: phoneCtrl.text,
                      ccpNumber: ccpCtrl.text,
                      role: roleCtrl.text,
                      operatorId: user.operatorId,
                      createdAt: user.createdAt,
                    );
                    await ref
                        .read(userRepositoryProvider)
                        .updateUser(updatedUser);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User ${user.fullName} updated'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating user: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    UserModel user,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryGreen.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    user.fullName[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(user.fullName)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: l10n.emailLabel, value: user.email),
                  _DetailRow(label: l10n.phoneLabel, value: user.phone ?? '—'),
                  _DetailRow(label: l10n.role, value: user.role.toUpperCase()),
                  if (user.role == 'client')
                    _DetailRow(
                      label: l10n.ccpLabel,
                      value: user.ccpNumber ?? '—',
                    ),
                  if (user.role != 'client')
                    _DetailRow(
                      label: l10n.operator,
                      value: user.operatorId ?? '—',
                    ),
                  _DetailRow(
                    label: l10n.joinedDate,
                    value: DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(user.createdAt),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'User ID:',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  SelectableText(
                    user.id,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 15, color: context.colors.onSurface),
          ),
        ],
      ),
    );
  }
}
