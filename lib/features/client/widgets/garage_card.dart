import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/domain/models/garage_model.dart';

class GarageCard extends StatelessWidget {
  final GarageModel garage;

  const GarageCard({super.key, required this.garage});

  IconData _getSpecialtyIcon(String s) {
    switch (s) {
      case 'mechanic':
        return Icons.build_outlined;
      case 'electric':
        return Icons.bolt_outlined;
      case 'tires':
        return Icons.tire_repair_outlined;
      case 'towing':
        return Icons.local_shipping_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accentGold = Color(0xFFC9A84C);
    const Color darkGreen = Color(0xFF1A3A2A);
    const Color cardWhite = Color(0xFFFFFFFF);
    const Color goldLight = Color(0xFFFDF3DC);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSpecialtyIcon(garage.specialty),
                  color: accentGold,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garage.name,
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      garage.ownerName ?? AppLocalizations.of(context)!.ownerNotSpecified,
                      style: TextStyle(
                        color: context.colors.slate500,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: accentGold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${garage.rating}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 8),
                        Text(
                          garage.wilaya,
                          style: TextStyle(
                            color: context.colors.slate500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: goldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.appDiscountLabel(garage.discountPercent),
                  style: TextStyle(
                    color: accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E5E5), height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (garage.latitude != null && garage.longitude != null) {
                      launchUrl(
                        Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${garage.latitude},${garage.longitude}',
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.viewOnMap,
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkGreen,
                    side: const BorderSide(color: darkGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri.parse('tel:${garage.phone}')),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.actionCall,
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

