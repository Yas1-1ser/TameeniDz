import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/services/user_profile_service.dart';

import '../../../../../generated/l10n/app_localizations.dart';

enum _StepState { completed, active, upcoming }

/// Redesigned client Registration Step 3 Screen.
/// Uses the brand's Luxury Beige + Gold design system and preserves all business logic.
class Step3DocumentUpload extends StatefulWidget {
  const Step3DocumentUpload({super.key});

  @override
  State<Step3DocumentUpload> createState() => _Step3DocumentUploadState();
}

class _Step3DocumentUploadState extends State<Step3DocumentUpload> {
  PlatformFile? _nationalIdFile;
  PlatformFile? _proofOfAddressFile;
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
              _errorMessage = 'حجم الملف يتجاوز الحد الأقصى المسموح به وهو 5 ميجابايت';
            } else if (lang == 'fr') {
              _errorMessage = 'La taille du fichier dépasse la limite maximale de 5 Mo';
            } else {
              _errorMessage = 'File size exceeds the maximum limit of 5MB';
            }
          });
          return;
        }
        setState(() {
          if (type == 'national_id') {
            _nationalIdFile = file;
          } else {
            _proofOfAddressFile = file;
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
      if (type == 'national_id') {
        _nationalIdFile = null;
      } else {
        _proofOfAddressFile = null;
      }
    });
  }

  bool get _canSubmit =>
      _nationalIdFile != null && _proofOfAddressFile != null && !_isUploading;

  Future<void> _submitDocuments(AppLocalizations l10n) async {
    if (!_canSubmit) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.unauthenticatedError);

      final files = [
        ('national_id', _nationalIdFile!),
        ('proof_of_address', _proofOfAddressFile!),
      ];

      for (int i = 0; i < files.length; i++) {
        final (docType, file) = files[i];
        final ext = file.extension ?? 'pdf';
        final storagePath = 'users/$userId/documents/$docType.$ext';

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

        if (mounted) {
          setState(() => _uploadProgress = (i + 1) / files.length);
        }
      }

      await UserProfileService(client).markDocumentsSubmitted(userId);

      if (mounted) {
        setState(() => _isUploading = false);
        context.go('/client');
      }
    } on StorageException catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = '${l10n.uploadFileError}: ${e.message}';
        });
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

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: context.colors.darkText,
            size: 22,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/register/step2');
            }
          },
        ),
        title: Text(
          l10n.documents,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: context.colors.darkText,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: PageEntryAnimation(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Horizontal Stepper Progress Tracker - Standardized 1-2-3
                _buildStepper(l10n),
                const SizedBox(height: 28),

                Text(
                  l10n.uploadDocumentsSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.slate500,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'الحجم الأقصى للملف الواحد: 5 ميجابايت (PDF أو صور)'
                      : (Localizations.localeOf(context).languageCode == 'fr'
                          ? 'Taille max par fichier : 5 Mo (PDF ou images)'
                          : 'Max size per file: 5MB (PDF or images)'),
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.slate400,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Upload list
                _buildUploadCard(
                  title: l10n.nationalId,
                  subtitle: l10n.uploadNationalIdHint,
                  icon: Icons.badge_outlined,
                  file: _nationalIdFile,
                  onTap: () => _pickDocument('national_id', l10n),
                  onRemove: () => _removeDocument('national_id'),
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                _buildUploadCard(
                  title: l10n.proofOfAddress,
                  subtitle: l10n.uploadProofOfAddressHint,
                  icon: Icons.home_outlined,
                  file: _proofOfAddressFile,
                  onTap: () => _pickDocument('proof_of_address', l10n),
                  onRemove: () => _removeDocument('proof_of_address'),
                  l10n: l10n,
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  _buildErrorBanner(),
                  const SizedBox(height: 16),
                ],

                if (_isUploading) ...[
                  _buildProgress(l10n),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                _buildSubmitButton(l10n),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(number: '1', title: l10n.information, state: _StepState.completed),
        _buildStepDivider(isGold: true),
        _buildStepNode(number: '2', title: l10n.verification, state: _StepState.completed),
        _buildStepDivider(isGold: true),
        _buildStepNode(number: '3', title: l10n.documents, state: _StepState.active),
      ],
    );
  }

  Widget _buildStepDivider({bool isGold = false}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isGold ? AppColors.goldAccent : context.colors.warmDivider,
      ),
    );
  }

  Widget _buildStepNode({
    required String number,
    required String title,
    required _StepState state,
  }) {
    Color circleColor;
    Color borderColor;
    Widget content;
    Color textColor;

    switch (state) {
      case _StepState.completed:
        circleColor = AppColors.goldAccent;
        borderColor = AppColors.goldAccent;
        content = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
        textColor = AppColors.goldAccent;
        break;
      case _StepState.active:
        circleColor = Colors.white;
        borderColor = AppColors.goldAccent;
        content = Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.goldAccent,
          ),
        );
        textColor = AppColors.goldAccent;
        break;
      case _StepState.upcoming:
        circleColor = context.colors.beigeCard;
        borderColor = AppColors.goldAccent.withValues(alpha: 0.25);
        content = Text(
          number,
          style: TextStyle(
            color: AppColors.goldAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
        textColor = context.colors.slate400;
        break;
    }

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(color: borderColor, width: 2),
            ),
            alignment: Alignment.center,
            child: content,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: state == _StepState.active ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _uploadProgress,
            color: AppColors.primaryGreen,
            backgroundColor: context.colors.warmDivider,
            minHeight: 6,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${(_uploadProgress * 100).toInt()}%',
          style: TextStyle(fontSize: 12, color: context.colors.slate500, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Column(
      children: [
        GestureDetector(
          onTap: _canSubmit ? () => _submitDocuments(l10n) : null,
          child: Opacity(
            opacity: _canSubmit ? 1.0 : 0.6,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF247E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppColors.goldAccent.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(
                      l10n.completeRegistration,
                      style: TextStyle(
                        color: context.colors.surface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
            ),
          ),
        ),
        if (!_isUploading) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go('/client'),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.skip,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ],
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
        style: const TextStyle(fontSize: 13, color: AppColors.rejected, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
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
    required AppLocalizations l10n,
  }) {
    final hasFile = file != null;

    return GestureDetector(
      onTap: _isUploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.beigeCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? AppColors.accepted : AppColors.goldAccent.withValues(alpha: 0.28),
            width: hasFile ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.accepted.withValues(alpha: 0.1)
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile ? Icons.check_circle_rounded : icon,
                color: hasFile ? AppColors.accepted : AppColors.goldAccent,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.darkText,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: context.colors.slate500, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (hasFile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.colors.beigeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 16,
                      color: AppColors.goldAccent,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        file.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.darkText,
                          fontFamily: 'Cairo',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isUploading ? null : onRemove,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.rejected,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                'PDF / JPG / PNG',
                style: TextStyle(fontSize: 12, color: context.colors.slate400, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
