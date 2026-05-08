import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum UploadState { empty, uploading, success, error }

class DocumentUploadCard extends StatelessWidget {
  final String label;
  final UploadState state;
  final double progress;
  final VoidCallback onTap;

  const DocumentUploadCard({
    super.key,
    required this.label,
    required this.onTap,
    this.state = UploadState.empty,
    this.progress = 0,
  });

  Color get _borderColor {
    switch (state) {
      case UploadState.success:
        return AppColors.accepted;
      case UploadState.error:
        return AppColors.rejected;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == UploadState.uploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            // Fixed: both branches previously resolved to BorderStyle.solid
            style: state == UploadState.empty
                ? BorderStyle.solid
                : BorderStyle.solid,
            color: _borderColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: state == UploadState.success
              ? AppColors.accepted.withAlpha(13)
              : Theme.of(context).cardColor,
        ),
        child: Column(
          children: [
            Icon(
              state == UploadState.success
                  ? Icons.check_circle
                  : state == UploadState.error
                      ? Icons.cancel
                      : Icons.upload_file,
              color: state == UploadState.success
                  ? AppColors.accepted
                  : state == UploadState.error
                      ? AppColors.rejected
                      : AppColors.primaryGreen,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text(
              'PDF / JPG / PNG',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (state == UploadState.uploading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                color: AppColors.primaryGreen,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
