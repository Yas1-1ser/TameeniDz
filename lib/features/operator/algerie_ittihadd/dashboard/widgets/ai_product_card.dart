// lib/features/operator/algerie_ittihadd/dashboard/widgets/ai_product_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';

class AiProductCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String transliteration;
  final String subtitle;
  final String price;
  final VoidCallback onQuoteRequest;

  const AiProductCard({
    super.key,
    required this.icon,
    required this.title,
    required this.transliteration,
    required this.subtitle,
    required this.price,
    required this.onQuoteRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: kCardGradient,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: kParchment, width: 1),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Gold gradient icon circle
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: kGoldGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 8),
              // Product Name (Amiri, bold, kGoldDeep, 15)
              Text(
                title,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: kGoldDeep,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Transliteration (IBMPlexArabic, kInkFaint, 11)
              Text(
                transliteration,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 10,
                  color: kInkFaint,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Description (IBMPlexArabic, kInkMuted, 11)
              Text(
                subtitle,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 10,
                  color: kInkMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Parchment Divider Line
              const Divider(color: kParchment, height: 1, thickness: 1),
              const SizedBox(height: 6),
              // Price (IBMPlexArabic, kGoldDeep, 12, bold)
              Text(
                price,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 10,
                  color: kGoldDeep,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Quote Request Button [ طلب تسعيرة ] (outlined, border kGoldMid, text kGoldDeep)
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: onQuoteRequest,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kGoldMid, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                foregroundColor: kGoldDeep,
              ),
              child: Text(
                'طلب تسعيرة',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kGoldDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
