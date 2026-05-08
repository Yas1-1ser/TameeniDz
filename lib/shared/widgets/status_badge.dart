import 'package:flutter/material.dart';
import '../enums/policy_status.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../generated/l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final PolicyStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final Map<PolicyStatus, (Color, String)> config = {
      PolicyStatus.pending: (colors.pending, l10n.statusPending),
      PolicyStatus.accepted: (colors.accepted, l10n.statusAccepted),
      PolicyStatus.rejected: (colors.rejected, l10n.statusRejected),
      PolicyStatus.modificationRequested: (colors.modRequested, l10n.statusModReq),
    };
    
    final (color, label) = config[status]!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
