import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import '../../../../core/providers/service_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'email_verification_modal.dart';

class EmailVerificationBanner extends ConsumerWidget {
  const EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailVerifiedAsync = ref.watch(emailVerifiedProvider);

    return emailVerifiedAsync.when(
      data: (isVerified) {
        if (isVerified) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.goldLight,
            border: Border(
              bottom: BorderSide(color: AppColors.beigeGold, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 20,
                color: AppColors.beigeGold,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.emailVerificationRequired,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.goldDeep,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const EmailVerificationModal(),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.of(context)!.confirmNow,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldDeep,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
