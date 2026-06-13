import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

/// Displays a read-only, immutable audit timestamp (Decree 21-81 requirement).
class ImmutableTimestamp extends StatelessWidget {
  final DateTime timestamp;
  const ImmutableTimestamp({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${timestamp.year}-${_p(timestamp.month)}-${_p(timestamp.day)} | '
        '${_p(timestamp.hour)}:${_p(timestamp.minute)}:${_p(timestamp.second)}';
    return Row(
      children: [
        const Icon(Icons.lock_clock, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '${AppLocalizations.of(context)!.registeredAt} $formatted',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

