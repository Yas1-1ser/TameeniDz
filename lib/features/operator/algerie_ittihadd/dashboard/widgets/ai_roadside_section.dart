// lib/features/operator/algerie_ittihadd/dashboard/widgets/ai_roadside_section.dart
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class AiRoadsideSection extends StatelessWidget {
  const AiRoadsideSection({super.key});

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kParchment, width: 1),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(Icons.car_repair_rounded, color: kGoldDeep, size: 20),
              const SizedBox(width: 8),
              Text(
                'المساعدة على الطريق والورشات',
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kGoldDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SOS Emergency Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(kRadiusSm),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خط الطوارئ الساخن الموحد',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'اتصل فوراً للحصول على مساعدة عاجلة 24/7',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.sos);
                  },
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'طوارئ 3030',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: context.colors.surface,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    elevation: 0,
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusSm),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Collapsible list of verified workshops
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                'ورشات ميكانيك معتمدة',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kInk,
                ),
              ),
              children: [
                _buildWorkshopTile(
                  'ورشة الأمان — باب الزوار، الجزائر',
                  '021 50 60 70',
                ),
                const Divider(color: kParchment),
                _buildWorkshopTile(
                  'ورشة النخبة — أولاد فايت، الجزائر',
                  '023 40 50 60',
                ),
              ],
            ),
          ),
          const Divider(color: kParchment),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                'خدمات سحب وقطر السيارات',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kInk,
                ),
              ),
              children: [
                _buildWorkshopTile(
                  'قطر النجدة السريع — متوفر 24/7',
                  '0550 11 22 33',
                ),
                const Divider(color: kParchment),
                _buildWorkshopTile(
                  'سحب الاتحاد الآمن — تغطية وطنية',
                  '0661 44 55 66',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopTile(String name, String phone) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        name,
        style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, color: kInk),
      ),
      subtitle: Text(
        'الهاتف: $phone',
        style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: kInkMuted),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call_rounded, color: kGoldDeep),
        onPressed: () => _makeCall(phone),
      ),
    );
  }
}
