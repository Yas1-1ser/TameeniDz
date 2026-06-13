import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../../features/shared/widgets/email_verification_banner.dart';
import 'legal_providers.dart';
import '../../shared/data/legal_repository.dart';

class LegalHubScreen extends ConsumerWidget {
  const LegalHubScreen({super.key});

  Future<void> _handleDownload(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final repo = ref.read(legalRepositoryProvider);

    final url = await repo.getDossierDownloadUrl();

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Could not launch download URL')),
        );
      }
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Dossier file not found in storage')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(legalSectionsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Localizations.localeOf(context).languageCode == 'ar'
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_rounded,
            size: 20,
          ),
          onPressed: () => context.go('/client'),
        ),
        title: Text(
          l10n.legal,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: PageEntryAnimation(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const EmailVerificationBanner(),
              // Premium Elite Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.legalComplianceHub,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: context.colors.surface,
                        letterSpacing: -0.02,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.legalCompliancePortalSubtitle,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleDownload(context, ref),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: Text(l10n.downloadDossier),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Bento Grid
                    _buildMediationMandate(context, l10n),
                    const SizedBox(height: 24),
                    _buildDecreeCard(context, l10n),
                    const SizedBox(height: 32),

                    Text(
                      l10n.whyWeAreLegal,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPillarCard(
                      context,
                      icon: Icons.gavel,
                      title: l10n.wakalaPrinciple,
                      description: l10n.wakalaPrincipleDesc,
                    ),
                    const SizedBox(height: 16),
                    _buildPillarCard(
                      context,
                      icon: Icons.verified_user,
                      title: l10n.shariaOversightTitle,
                      description: l10n.shariaOversightDesc,
                    ),
                    const SizedBox(height: 16),
                    _buildPillarCard(
                      context,
                      icon: Icons.all_inclusive,
                      title: l10n.subscribersFundTitle,
                      description: l10n.subscribersFundDesc,
                    ),
                    const SizedBox(height: 16),
                    _buildPillarCard(
                      context,
                      icon: Icons.people,
                      title: l10n.socialTakafulTitle,
                      description: l10n.socialTakafulDesc,
                    ),
                    const SizedBox(height: 32),

                    Text(
                      l10n.regulatoryLawsTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLawCard(context, l10n.lawOrder9507),
                    const SizedBox(height: 12),
                    _buildLawCard(context, l10n.lawDecree2181),
                    const SizedBox(height: 12),
                    _buildLawCard(context, l10n.lawFinanceMinistry2021),
                    const SizedBox(height: 40),

                    sectionsAsync.when(
                      data:
                          (sections) => Column(
                            children:
                                sections
                                    .map(
                                      (s) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        child: _buildPillarCard(
                                          context,
                                          icon: _getIcon(s.iconName),
                                          title: s.title,
                                          description: s.content,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'visibility':
        return Icons.visibility;
      case 'shield':
        return Icons.shield;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildMediationMandate(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant,
        ), // outline-variant
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTint, // 5% primary tint
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.goldAccent, // Gold Accent
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(
                          alpha: 0.1,
                        ), // soft green background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.balance,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.mediationMandate,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: context.colors.darkText, // Dark Text
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.mediationMandateContent,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    height: 1.6,
                    color:
                        context.colors.onSurfaceVariant, // on-surface-variant
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecreeCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen, // Primary Green
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryOverlay,
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified,
                color: AppColors.onPrimaryContainerSoft,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.decreeFrameworkTitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.surface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.decreeFrameworkDescription,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              height: 1.5,
              color: AppColors.inversePrimary, // inverse-primary (soft green)
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.statusLabel,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.inversePrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark, // darker green
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.onPrimaryContainerSoft),
                  ),
                  child: Text(
                    l10n.activeAudited,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryContainerSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.transparent)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.lastReviewLabel,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.inversePrimary,
                    ),
                  ),
                ),
                Text(
                  'Oct 14, 2023',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.surface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTintLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  context.colors.surfaceContainerLow, // surface-container-low
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              height: 1.5,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawCard(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: AppColors.goldAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.colors.darkText,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
