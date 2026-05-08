import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../shared/widgets/portal_layout.dart';

class PolicyDocumentUploadScreen extends ConsumerStatefulWidget {
  final String policyId;
  const PolicyDocumentUploadScreen({super.key, required this.policyId});

  @override
  ConsumerState<PolicyDocumentUploadScreen> createState() => _PolicyDocumentUploadScreenState();
}

class _PolicyDocumentUploadScreenState extends ConsumerState<PolicyDocumentUploadScreen> {
  PlatformFile? _carIdentityFile;
  PlatformFile? _localCertificateFile;
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
        setState(() {
          if (type == 'car_identity') {
            _carIdentityFile = result.files.first;
          } else {
            _localCertificateFile = result.files.first;
          }
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
      if (type == 'car_identity') {
        _carIdentityFile = null;
      } else {
        _localCertificateFile = null;
      }
    });
  }

  bool get _canSubmit =>
      _carIdentityFile != null && _localCertificateFile != null && !_isUploading;

  Future<void> _submitDocuments(AppLocalizations l10n) async {
    if (!_canSubmit) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      final client = ref.read(supabaseProvider);
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.unauthenticatedError);

      final files = [
        ('car_identity', _carIdentityFile!),
        ('local_certificate', _localCertificateFile!),
      ];

      List<Map<String, String>> uploadedUrls = [];

      for (int i = 0; i < files.length; i++) {
        final (docType, file) = files[i];
        final ext = file.extension ?? 'pdf';
        final storagePath = 'policies/${widget.policyId}/$docType.$ext';

        if (kIsWeb) {
          final bytes = file.bytes;
          if (bytes == null) throw Exception(l10n.unexpectedError);
          await client.storage.from('documents').uploadBinary(
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
          await client.storage.from('documents').upload(
                storagePath,
                File(path),
                fileOptions: FileOptions(
                  contentType: _mimeType(ext),
                  upsert: true,
                ),
              );
        }

        final publicUrl = client.storage.from('documents').getPublicUrl(storagePath);
        uploadedUrls.add({
          'label': docType == 'car_identity' ? 'Car Identity' : 'Local Certificate',
          'url': publicUrl,
        });

        if (mounted) {
          setState(() => _uploadProgress = (i + 1) / files.length);
        }
      }

      // Update the policy with document URLs
      await client.from('policies').update({
        'document_urls': uploadedUrls,
      }).eq('id', widget.policyId);

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.statusUpdateSuccess),
            backgroundColor: AppColors.accepted,
          ),
        );
        context.go('/client/policies');
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

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return PortalLayout(
      selectedIndex: 0,
      menuItems: menuItems,
      portalTitle: l10n.uploadDocuments,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/client/policies',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                'Please upload the required car documentation for Policy #${widget.policyId.substring(0, 8).toUpperCase()}',
                style: TextStyle(fontSize: 14, color: colors.slate500),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildUploadCard(
                      title: l10n.carIdentity,
                      subtitle: l10n.uploadCarIdentityHint,
                      icon: Icons.directions_car_outlined,
                      file: _carIdentityFile,
                      onTap: () => _pickDocument('car_identity', l10n),
                      onRemove: () => _removeDocument('car_identity'),
                      colors: colors,
                    ),
                    const SizedBox(height: 20),
                    _buildUploadCard(
                      title: l10n.localCertificate,
                      subtitle: l10n.uploadLocalCertificateHint,
                      icon: Icons.assignment_outlined,
                      file: _localCertificateFile,
                      onTap: () => _pickDocument('local_certificate', l10n),
                      onRemove: () => _removeDocument('local_certificate'),
                      colors: colors,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      _buildErrorBanner(),
                    ],
                  ],
                ),
              ),
              if (_isUploading) _buildProgress(colors),
              const SizedBox(height: 16),
              _buildSubmitButton(l10n),
            ],
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

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canSubmit ? () => _submitDocuments(l10n) : null,
        child: _isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(l10n.submit),
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
            color: hasFile ? AppColors.accepted : colors.slate200,
            width: hasFile ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : icon,
              color: hasFile ? AppColors.accepted : AppColors.primaryGreen,
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
                    child: const Icon(Icons.close, size: 16, color: AppColors.rejected),
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
