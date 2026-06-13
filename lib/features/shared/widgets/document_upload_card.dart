import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == UploadState.uploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                state == UploadState.success
                    ? AppColors.accepted
                    : state == UploadState.error
                    ? AppColors.rejected
                    : Colors.grey.shade400,
            width: 1.5,
            style:
                state == UploadState.empty
                    ? BorderStyle.solid
                    : BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              state == UploadState.success
                  ? AppColors.accepted.withValues(alpha: 0.05)
                  : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              state == UploadState.success
                  ? Icons.check_circle
                  : state == UploadState.error
                  ? Icons.cancel
                  : Icons.upload_file,
              color:
                  state == UploadState.success
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
