import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import '../../../../features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/client/policies/policy_providers.dart';
import 'package:tameenidz/features/shared/data/policy_repository.dart';
import 'package:tameenidz/core/utils/service_documents.dart';

class PolicyDocumentUploadScreen extends ConsumerStatefulWidget {
  final String policyId;
  const PolicyDocumentUploadScreen({super.key, required this.policyId});

  @override
  ConsumerState<PolicyDocumentUploadScreen> createState() =>
      _PolicyDocumentUploadScreenState();
}

class _PolicyDocumentUploadScreenState extends ConsumerState<PolicyDocumentUploadScreen> {
  final Map<String, PlatformFile> _selectedFiles = {};
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _errorMessage;

  Future<void> _pickDocument(String type, AppLocalizations l10n) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 5 * 1024 * 1024) {
          setState(() {
            final lang = Localizations.localeOf(context).languageCode;
            if (lang == 'ar') {
              _errorMessage = AppLocalizations.of(context)!.fileSizeExceedsLimit;
            } else if (lang == 'fr') {
              _errorMessage = 'La taille du fichier dépasse la limite maximale de 5 Mo';
            } else {
              _errorMessage = 'File size exceeds the maximum limit of 5MB';
            }
          });
          return;
        }
        setState(() {
          _selectedFiles[type] = file;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '${l10n.pickFileError}: $e');
      }
    }
  }

  void _removeDocument(String type) {
    setState(() {
      _selectedFiles.remove(type);
    });
  }

  bool _canSubmit(List<QuoteDocumentSpec> requiredDocs, PolicyModel policy) {
    if (_isUploading) return false;
    
    // Allow submit if at least one file is selected
    return _selectedFiles.isNotEmpty;
  }

  Future<void> _submitDocuments(AppLocalizations l10n, List<QuoteDocumentSpec> requiredDocs, PolicyModel policy) async {
    if (!_canSubmit(requiredDocs, policy)) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      final client = ref.read(supabaseProvider);
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.unauthenticatedError);

      List<Map<String, dynamic>> uploadedUrls = [];
      // Keep existing documents that are not being replaced
      final existingDocs = policy.documentUrls?.cast<Map<String, dynamic>>() ?? [];
      
      final filesToUpload = _selectedFiles.entries.toList();

      for (int i = 0; i < filesToUpload.length; i++) {
        final entry = filesToUpload[i];
        final docType = entry.key;
        final file = entry.value;
        final ext = file.extension ?? 'pdf';
        // Ensure path uses the docType as the file name, without spaces
        final storagePath = 'policies/${widget.policyId}/$docType.$ext';

        if (kIsWeb) {
          final bytes = file.bytes;
          if (bytes == null) throw Exception(l10n.unexpectedError);
          await client.storage
              .from('documents')
              .uploadBinary(
                storagePath,
                bytes,
                fileOptions: FileOptions(
                  contentType: _mimeType(ext),
                  upsert: true,
                ),
              );
        } else {
          final path = file.path;
          if (path == null) throw Exception(l10n.unexpectedError);
          await client.storage
              .from('documents')
              .upload(
                storagePath,
                File(path),
                fileOptions: FileOptions(
                  contentType: _mimeType(ext),
                  upsert: true,
                ),
              );
        }

        final spec = requiredDocs.firstWhere((d) => d.key == docType);
            
        uploadedUrls.add({
          'label': spec.labelEn, // or use English as a generic fallback since it's JSON
          'key': docType,
          'url': storagePath,
        });

        if (mounted) {
          setState(() => _uploadProgress = (i + 1) / filesToUpload.length);
        }
      }

      // Merge new documents with existing ones
      for (final existing in existingDocs) {
        final existingKey = existing['key'];
        // if not uploaded this time, keep the old one
        if (!uploadedUrls.any((u) => u['key'] == existingKey)) {
          uploadedUrls.add(existing);
        }
      }

      // Update the policy with document URLs and reset status via PolicyRepository
      await ref.read(policyRepositoryProvider).resubmitDocuments(widget.policyId, uploadedUrls);

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.statusUpdateSuccess),
            backgroundColor: AppColors.accepted,
          ),
        );
        context.go('/client/policies/${widget.policyId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = '${l10n.unexpectedError}: $e';
        });
      }
    }
  }

  String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final policyAsync = ref.watch(clientPoliciesStreamProvider);
    
    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.folder_shared_rounded, l10n.myDocuments, AppRoutes.myPolicies),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return PortalLayout(
      selectedIndex: 2,
      menuItems: menuItems,
      portalTitle: l10n.uploadDocuments,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/client/policies',
      body: PageEntryAnimation(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: policyAsync.when(
              data: (policies) {
                final policy = policies.firstWhere(
                  (p) => p.id == widget.policyId,
                  orElse: () => policies.firstWhere((p) => p.id.startsWith(widget.policyId)),
                );
                
                final requiredDocs = ServiceDocuments.forPolicy(policy);
                final existingDocs = policy.documentUrls?.cast<Map<String, dynamic>>() ?? [];
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.uploadDocuments,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.pleaseUploadRequiredDocsForReassessment(policy.planName ?? ''),
                      style: TextStyle(fontSize: 14, color: colors.slate500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? AppLocalizations.of(context)!.maxFileSize5MB
                          : (Localizations.localeOf(context).languageCode == 'fr'
                              ? 'Taille max par fichier : 5 Mo (PDF ou images)'
                              : 'Maximum file size: 5MB per file (PDF or images)'),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.slate400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView.separated(
                        itemCount: requiredDocs.length + (_errorMessage != null ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index == requiredDocs.length) {
                            return _buildErrorBanner();
                          }
                          
                          final doc = requiredDocs[index];
                          final isUploadedPreviously = existingDocs.any((d) => d['key'] == doc.key);
                          
                          return _buildUploadCard(
                            title: doc.label('ar'),
                            subtitle: isUploadedPreviously ? AppLocalizations.of(context)!.uploadedPreviouslyChooseToEdit : AppLocalizations.of(context)!.pleaseChooseAFile,
                            icon: doc.icon,
                            file: _selectedFiles[doc.key],
                            onTap: () => _pickDocument(doc.key, l10n),
                            onRemove: () => _removeDocument(doc.key),
                            colors: colors,
                            isUploadedPreviously: isUploadedPreviously && !_selectedFiles.containsKey(doc.key),
                          );
                        },
                      ),
                    ),
                    if (_isUploading) _buildProgress(colors),
                    const SizedBox(height: 16),
                    _buildSubmitButton(l10n, requiredDocs, policy),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(AppColorsExtension colors) {
    return Column(
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _uploadProgress,
          color: AppColors.primaryGreen,
          backgroundColor: colors.slate200,
        ),
        const SizedBox(height: 4),
        Text(
          '${(_uploadProgress * 100).toInt()}%',
          style: TextStyle(fontSize: 12, color: colors.slate500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n, List<QuoteDocumentSpec> requiredDocs, PolicyModel policy) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canSubmit(requiredDocs, policy) ? () => _submitDocuments(l10n, requiredDocs, policy) : null,
        child:
            _isUploading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: context.colors.surface,
                    strokeWidth: 2,
                  ),
                )
                : Text(AppLocalizations.of(context)!.saveAndResubmit),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rejected.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.rejected.withValues(alpha: 0.3)),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(fontSize: 13, color: AppColors.rejected),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required PlatformFile? file,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    required AppColorsExtension colors,
    bool isUploadedPreviously = false,
  }) {
    final hasFile = file != null;

    return GestureDetector(
      onTap: _isUploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? AppColors.accepted : (isUploadedPreviously ? AppColors.primaryGreen : colors.slate200),
            width: hasFile || isUploadedPreviously ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : (isUploadedPreviously ? Icons.cloud_done_rounded : icon),
              color: hasFile || isUploadedPreviously ? AppColors.accepted : AppColors.primaryGreen,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: colors.slate500),
            ),
            if (hasFile) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      file.name,
                      style: TextStyle(fontSize: 12, color: colors.slate700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.rejected,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
