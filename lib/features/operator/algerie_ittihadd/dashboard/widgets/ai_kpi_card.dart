// lib/features/operator/algerie_ittihadd/dashboard/widgets/ai_kpi_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/widgets/animations/count_up_text.dart';

class AiKpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const AiKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: kCardGradient,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kParchment, width: 1),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        children: [
          // Icon Circle
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: kGoldGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          // CountUpText (numbers/stats → Cormorant)
          CountUpText(
            value: value.toDouble(),
            style: GoogleFonts.cormorant(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          const SizedBox(height: 4),
          // Label (IBMPlexArabic)
          Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 10,
              color: kInkMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
