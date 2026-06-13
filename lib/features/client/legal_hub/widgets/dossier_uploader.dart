import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/features/shared/data/legal_repository.dart';

class DossierUploader extends ConsumerStatefulWidget {
  const DossierUploader({super.key});

  @override
  ConsumerState<DossierUploader> createState() => _DossierUploaderState();
}

class _DossierUploaderState extends ConsumerState<DossierUploader> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 5 * 1024 * 1024) {
        if (mounted) {
          final lang = Localizations.localeOf(context).languageCode;
          String errorMsg = lang == 'ar'
              ? 'حجم الملف يتجاوز الحد الأقصى المسموح به وهو 5 ميجابايت'
              : (lang == 'fr'
                  ? 'La taille du fichier dépasse la limite maximale de 5 Mo'
                  : 'File size exceeds the maximum limit of 5MB');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        final file = result.files.first;
        final repo = ref.read(legalRepositoryProvider);
        
        if (kIsWeb) {
          await repo.uploadDossierBytes(file.bytes!);
        } else {
          await repo.uploadDossierFile(File(file.path!));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع الملف القانوني بنجاح', style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.beigeGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beigeGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: AppColors.beigeGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تحديث الملف القانوني (PDF)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo', color: AppColors.darkBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isUploading)
            const LinearProgressIndicator(color: AppColors.beigeGold)
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickAndUpload,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('اختيار ورفع ملف جديد', style: TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beigeGold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'الحجم الأقصى للملف هو 5 ميجابايت. سيتم استبدال الملف الحالي في المتجر السحابي.'
                : 'Maximum file size is 5MB. The current file will be replaced in the cloud store.',
            style: TextStyle(fontSize: 11, color: AppColors.midBrown, fontFamily: 'Cairo'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
