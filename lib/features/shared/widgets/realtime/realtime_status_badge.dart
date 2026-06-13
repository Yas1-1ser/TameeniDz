import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/services/realtime_manager.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class RealtimeStatusBadge extends StatelessWidget {
  final RealtimeManager manager;
  final VoidCallback onRetry;

  const RealtimeStatusBadge({
    super.key,
    required this.manager,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<RealtimeState>(
      stream: manager.stateStream,
      initialData: manager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        switch (state.status) {
          case RealtimeStatus.live:
            return _buildBadge(
              context: context,
              icon: Icons.circle,
              color: AppColors.statusGreenFg,
              text: l10n.realtimeLive,
            );
          case RealtimeStatus.connecting:
            return _buildBadge(
              context: context,
              icon: Icons.circle_outlined,
              color: AppColors.statusAmberFg,
              text: l10n.realtimeConnecting,
            );
          case RealtimeStatus.retrying:
            return _buildBadge(
              context: context,
              icon: Icons.sync,
              color: AppColors.statusAmberFg,
              text: l10n.realtimeRetrying,
              isAnimated: true,
            );
          case RealtimeStatus.failed:
            return GestureDetector(
              onTap: onRetry,
              child: _buildBadge(
                context: context,
                icon: Icons.error,
                color: AppColors.statusRedFg,
                text: l10n.realtimeTapToRetry,
              ),
            );
        }
      },
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String text,
    bool isAnimated = false,
  }) {
    final backgroundColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ] else ...[
            Icon(icon, size: 12, color: color),
          ],
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.ibmPlexSansArabic(
              color: AppColors.midBrown,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
