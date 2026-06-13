// lib/widgets/navigation/subscriber_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class SubscriberShell extends StatelessWidget {
  final Widget child;

  const SubscriberShell({super.key, required this.child});

  Future<bool?> _showExitDialog(BuildContext context) {
    
    return showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            backgroundColor: context.colors.beigeCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.darkText,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.exitConfirmMessage,
              style: TextStyle(color: context.colors.slate500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: context.colors.slate500),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.exit,
                  style: const TextStyle(color: AppColors.rejected),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Unused variables removed

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context) ?? false;
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
