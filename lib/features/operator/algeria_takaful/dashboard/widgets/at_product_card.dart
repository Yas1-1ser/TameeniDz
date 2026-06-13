// lib/features/operator/algeria_takaful/dashboard/widgets/at_product_card.dart
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';

class AtProductCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final VoidCallback onQuoteRequest;

  const AtProductCard({
    super.key,
    required this.icon,
    required this.title,
    required this.price,
    required this.onQuoteRequest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: colors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gold gradient icon circle
                  Container(
                    width: 42,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: kGoldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 8),
                  // Product Name
                  Text(
                    title,
                    style: GoogleFonts.amiri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: colors.darkText,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Divider(color: colors.outlineVariant, height: 12, indent: 20, endIndent: 20),
                  // Price
                  Flexible(
                    child: Text(
                      price,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Button Section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 34,
              child: OutlinedButton(
                onPressed: onQuoteRequest,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.goldAccent, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'طلب تسعيرة',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colors.darkText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
