import 'package:flutter/material.dart';
import 'realtime_manager.dart';

class RealtimeStatusBadge extends StatelessWidget {
  final Stream<RealtimeState> stateStream;
  final VoidCallback onRetry;

  const RealtimeStatusBadge({
    super.key,
    required this.stateStream,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealtimeState>(
      stream: stateStream,
      initialData: RealtimeState(status: RealtimeStatus.connecting),
      builder: (context, snapshot) {
        final state = snapshot.data!;

        switch (state.status) {
          case RealtimeStatus.live:
            return _buildBadge(
              context: context,
              icon: Icons.circle,
              color: Colors.green,
              text: 'Live',
            );
          case RealtimeStatus.connecting:
            return _buildBadge(
              context: context,
              icon: Icons.circle_outlined,
              color: Colors.orange,
              text: 'Connecting...',
            );
          case RealtimeStatus.retrying:
            return _buildBadge(
              context: context,
              icon: Icons.sync,
              color: Colors.orange,
              text: 'Timed out — retrying',
              isAnimated: true,
            );
          case RealtimeStatus.failed:
            return GestureDetector(
              onTap: onRetry,
              child: _buildBadge(
                context: context,
                icon: Icons.error,
                color: Colors.red,
                text: 'Tap to retry',
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
    // using withValues if available in Flutter >= 3.27, or fallback to withOpacity
    // To support potentially slightly older code without compilation errors while avoiding deprecation warnings where possible,
    // we use withValues.
    final backgroundColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.5);

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
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
