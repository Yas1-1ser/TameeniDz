import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/providers/supabase_provider.dart';
import 'package:tameenidz/core/services/user_profile_service.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/data/user_repository.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../shared/domain/models/user_model.dart';

// Helper localizations for keys not present in AppLocalizations
class _L10nHelper {
  static String delete(String locale) {
    switch (locale) {
      case 'ar': return 'حذف';
      case 'fr': return 'Supprimer';
      default: return 'Delete';
    }
  }

  static String forceDelete(String locale) {
    switch (locale) {
      case 'ar': return 'حذف إجباري (يمسح جميع البيانات المرتبطة)';
      case 'fr': return 'Suppression forcée (efface toutes les données liées)';
      default: return 'Force Delete (clears all related data)';
    }
  }

  static String userDeleted(String locale) {
    switch (locale) {
      case 'ar': return 'تم حذف المستخدم بنجاح';
      case 'fr': return 'Utilisateur supprimé avec succès';
      default: return 'User deleted successfully';
    }
  }

  static String userUpdated(String locale) {
    switch (locale) {
      case 'ar': return 'تم تحديث المستخدم بنجاح';
      case 'fr': return 'Utilisateur mis à jour avec succès';
      default: return 'User updated successfully';
    }
  }

  static String fieldRequired(String locale) {
    switch (locale) {
      case 'ar': return 'هذا الحقل مطلوب';
      case 'fr': return 'Ce champ est obligatoire';
      default: return 'This field is required';
    }
  }

  static String userDetailsTitle(String locale) {
    switch (locale) {
      case 'ar': return 'تفاصيل المستخدم';
      case 'fr': return 'Détails de l\'utilisateur';
      default: return 'User Details';
    }
  }

  static String documents(String locale) {
    switch (locale) {
      case 'ar': return 'الوثائق';
      case 'fr': return 'Documents';
      default: return 'Documents';
    }
  }

  static String approve(String locale) {
    switch (locale) {
      case 'ar': return 'قبول';
      case 'fr': return 'Approuver';
      default: return 'Approve';
    }
  }

  static String reject(String locale) {
    switch (locale) {
      case 'ar': return 'رفض';
      case 'fr': return 'Rejeter';
      default: return 'Reject';
    }
  }
}

class UserDialogHelper {
  static void showAddUserDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.addUser, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
              title: Text(l10n.client, style: const TextStyle(fontFamily: 'Cairo')),
              subtitle: Text(l10n.clientRoleSubtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                context.push('/role/client');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business_outlined, color: AppColors.goldAccent),
              title: Text(l10n.operatorRole, style: const TextStyle(fontFamily: 'Cairo')),
              subtitle: Text(l10n.operatorRoleSubtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                context.push('/operator/register');
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
  }

  static void showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AppLocalizations l10n,
  ) {
    final locale = l10n.localeName;
    bool forceDelete = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(l10n.deleteUser, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteUserConfirmation,
                style: const TextStyle(fontFamily: 'Cairo', height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: forceDelete,
                    onChanged: (val) => setState(() => forceDelete = val ?? false),
                    activeColor: AppColors.error,
                  ),
                  Expanded(
                    child: Text(
                      _L10nHelper.forceDelete(locale),
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: TextStyle(fontFamily: 'Cairo', color: context.colors.slate500)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(userRepositoryProvider).deleteUser(user.id, force: forceDelete);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_L10nHelper.userDeleted(locale), style: const TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    final errorMsg = e.toString().contains('500') || e.toString().contains('foreign key')
                      ? (locale == 'ar' ? 'لا يمكن حذف المستخدم بسبب وجود بيانات مرتبطة به. يرجى تفعيل "الحذف الإجباري".' : 'Cannot delete user: related data exists. Please enable "Force Delete".')
                      : e.toString();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg, style: const TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(_L10nHelper.delete(locale), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  static void showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AppLocalizations l10n,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    final ccpController = TextEditingController(text: user.ccpNumber);
    final locale = l10n.localeName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.editUser, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? _L10nHelper.fieldRequired(locale) : null,
                ),
                if (user.role == 'client') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ccpController,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      labelText: l10n.ccpLabel,
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final updatedUser = user.copyWith(
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    ccpNumber: ccpController.text.trim(),
                  );
                  await ref.read(userRepositoryProvider).updateUser(updatedUser);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_L10nHelper.userUpdated(locale), style: const TextStyle(fontFamily: 'Cairo'))),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.save, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void showUserDetails(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AppLocalizations l10n,
  ) {
    final locale = l10n.localeName;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: context.colors.slate200, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _L10nHelper.userDetailsTitle(locale),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: AppColors.primaryGreen),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(context, l10n.fullName, user.fullName, Icons.person_outline_rounded),
              _buildDetailItem(context, l10n.emailLabel, user.email, Icons.alternate_email_rounded),
              _buildDetailItem(context, l10n.role, user.role.toUpperCase(), Icons.badge_outlined),
              if (user.role == 'client') ...[
                _buildDetailItem(context, l10n.phoneLabel, user.phone ?? '—', Icons.phone_android_rounded),
                _buildDetailItem(context, l10n.ccpLabel, user.ccpNumber ?? '—', Icons.account_balance_wallet_outlined),
                const Divider(height: 40),
                Text(
                  _L10nHelper.documents(locale),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 16),
                if (user.documentsSubmitted) ...[
                  _buildDocumentSection(context, ref, user, locale),
                ] else ...[
                  Text('No documents uploaded yet.', style: TextStyle(fontFamily: 'Cairo', color: context.colors.slate500)),
                ],
              ] else
                _buildDetailItem(context, l10n.operator, user.operatorId ?? '—', Icons.corporate_fare_rounded),
              _buildDetailItem(
                context,
                l10n.joinedDate,
                DateFormat('yyyy-MM-dd – HH:mm').format(user.createdAt),
                Icons.calendar_month_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDocumentSection(BuildContext context, WidgetRef ref, UserModel user, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildDocButton(context, ref, user, 'national_id', 'National ID', locale),
            const SizedBox(width: 12),
            _buildDocButton(context, ref, user, 'proof_of_address', 'Proof of Address', locale),
          ],
        ),
        const SizedBox(height: 24),
        if (user.documentStatus == 'pending') ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, ref, user, 'approved'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                  child: Text(_L10nHelper.approve(locale), style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, ref, user, 'rejected'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                  child: Text(_L10nHelper.reject(locale), style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: user.documentStatus == 'approved' ? AppColors.primaryGreen.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  user.documentStatus == 'approved' ? Icons.check_circle : Icons.cancel,
                  color: user.documentStatus == 'approved' ? AppColors.primaryGreen : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${user.documentStatus.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: user.documentStatus == 'approved' ? AppColors.primaryGreen : AppColors.error,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildDocButton(BuildContext context, WidgetRef ref, UserModel user, String type, String label, String locale) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final supabase = ref.read(supabaseProvider);
          // Try both jpg and pdf since we don't store extension in DB yet
          // In a real app, you'd store the full path or extension
          String? url;
          for (var ext in ['jpg', 'jpeg', 'png', 'pdf']) {
            try {
              final path = 'users/${user.id}/documents/$type.$ext';
              final response = await supabase.storage.from('documents').createSignedUrl(path, 60);
              url = response;
              break;
            } catch (_) {}
          }

          if (url != null && context.mounted) {
            // Simple dialog to show document (if image) or link
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(label),
                content: url!.contains('.pdf') 
                  ? const Text('PDF Document. Opening in browser...')
                  : Image.network(url!),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.slate200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.goldAccent),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _updateStatus(BuildContext context, WidgetRef ref, UserModel user, String status) async {
    try {
      final service = UserProfileService(ref.read(supabaseProvider));
      await service.updateDocumentStatus(user.id, status);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document status updated to $status')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  static Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: context.colors.slate500, fontFamily: 'Cairo')),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: context.colors.darkText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
