// lib/features/operator/widgets/shared_info_cards.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class LegalComplianceCard extends StatelessWidget {
  const LegalComplianceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kParchment, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            l10n.whyLegal,
            style: GoogleFonts.amiri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            _buildComplianceRow(l10n.order9507, l10n.order9507Desc),
            const Divider(color: kParchment, height: 16),
            _buildComplianceRow(l10n.decree2181, l10n.decree2181Desc),
            const Divider(color: kParchment, height: 16),
            _buildComplianceRow(l10n.financeMinistry2021, l10n.financeMinistry2021Desc),
            const Divider(color: kParchment, height: 16),
            _buildComplianceRow(l10n.nationalShariahBody, l10n.nationalShariahBodyDesc),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceRow(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.verified_rounded, color: kGoldMid, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: kInkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TakafulPhilosophyCard extends StatelessWidget {
  const TakafulPhilosophyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kParchment, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            l10n.takafulPhilosophy,
            style: GoogleFonts.amiri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.takafulDescription,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                color: kInkMuted,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(l10n.chipAgency),
                _buildChip(l10n.chipShariahOversight),
                _buildChip(l10n.chipSubscribersFund),
                _buildChip(l10n.chipSocialTakaful),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kParchment,
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: kGoldDeep,
        ),
      ),
    );
  }
}
