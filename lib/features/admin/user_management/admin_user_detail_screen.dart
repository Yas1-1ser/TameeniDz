import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import '../user_management/user_providers.dart';
import '../../shared/domain/models/user_model.dart';
import 'widgets/user_filters.dart';

class AdminUserDetailScreen extends ConsumerWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final usersAsync = ref.watch(usersStreamProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: buildAdminAppBar(
        context, 
        l10n.userDetails,
        actions: [
          IconButton(
            icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, color: colors.goldAccent),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: adminBottomNav(context, 3, l10n),
      body: PageEntryAnimation(
        child: usersAsync.when(
          data: (users) {
            final user = users.firstWhere(
              (u) => u.id == userId, 
              orElse: () => UserModel(
                id: userId,
                fullName: l10n.unknown,
                email: 'unknown@example.com',
                role: 'client',
                createdAt: DateTime.now(),
              ),
            );
            
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  StaggeredListItem(
                    delay: const Duration(milliseconds: 0),
                    child: _buildProfileHeader(context, user),
                  ),
                  const SizedBox(height: 24),
                  StaggeredListItem(
                    delay: const Duration(milliseconds: 100),
                    child: _buildDetailCard(context, user, l10n, ref),
                  ),
                  const SizedBox(height: 24),
                  if (user.role == 'client')
                    StaggeredListItem(
                      delay: const Duration(milliseconds: 200),
                      child: _buildDocumentsSection(context, user, l10n),
                    ),
                  const SizedBox(height: 32),
                  StaggeredListItem(
                    delay: const Duration(milliseconds: 300),
                    child: _buildActionButtons(context, ref, user, l10n),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.goldAccent)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(fontFamily: 'Cairo'))),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    final colors = context.colors;
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.goldAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: colors.surface,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: colors.darkText, fontFamily: 'Cairo'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo'),
          ),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, UserModel user, AppLocalizations l10n, WidgetRef ref) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.personalInfo,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo'),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colors.goldAccent, size: 20),
                onPressed: () => UserDialogHelper.showEditUserDialog(context, ref, user, l10n),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(context, l10n.role, user.role.toUpperCase(), Icons.badge_outlined),
          Divider(color: colors.beigeBg, height: 24),
          if (user.role == 'client') ...[
            _buildDetailRow(context, l10n.phoneLabel, user.phone ?? '—', Icons.phone_android_rounded),
            Divider(color: colors.beigeBg, height: 24),
            _buildDetailRow(context, l10n.ccpLabel, user.ccpNumber ?? '—', Icons.account_balance_wallet_outlined),
            Divider(color: colors.beigeBg, height: 24),
          ] else ...[
            _buildDetailRow(context, l10n.operator, user.operatorId ?? '—', Icons.corporate_fare_rounded),
            Divider(color: colors.beigeBg, height: 24),
          ],
          _buildDetailRow(context, l10n.joinedDate, DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt), Icons.calendar_today_rounded),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11, fontFamily: 'Cairo'),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.darkText, fontSize: 14, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context, UserModel user, AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            l10n.uploadedDocuments,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo'),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              _buildDocTile(context, l10n.nationalId, Icons.contact_page_outlined),
              Divider(color: colors.beigeBg, height: 24),
              _buildDocTile(context, l10n.proofOfAddress, Icons.home_work_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocTile(BuildContext context, String title, IconData icon) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: colors.beigeBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: colors.goldAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo', color: colors.darkText),
          ),
        ),
        TextButton(
          onPressed: () {}, // Future: open doc viewer
          child: Text(AppLocalizations.of(context)!.viewDetails, style: TextStyle(color: colors.goldAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, UserModel user, AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => UserDialogHelper.showEditUserDialog(context, ref, user, l10n),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton.icon(
            onPressed: () => UserDialogHelper.showDeleteConfirmation(context, ref, user, l10n),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusRedFg),
            label: Text(l10n.delete, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusRedFg, fontSize: 16, fontFamily: 'Cairo')),
          ),
        ),
      ],
    );
  }
}
