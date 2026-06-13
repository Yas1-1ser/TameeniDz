import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class GarageCard extends StatelessWidget {
  final Map<String, dynamic> garage;

  const GarageCard({super.key, required this.garage});

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                garage['name'] ?? AppLocalizations.of(context)!.garageUnknown,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${garage['rating'] ?? 'N/A'}/5',
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.specialties,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ((garage['specialties'] as List<dynamic>?) ?? []).map((spec) {
                  return Chip(
                    label: Text(spec.toString(), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: context.colors.offWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(fontFamily: 'Cairo')),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final specialties = (garage['specialties'] as List<dynamic>?)?.join(' · ') ?? '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    garage['name'] ?? AppLocalizations.of(context)!.garageUnknown,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${garage['rating'] ?? 'N/A'}/5',
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              specialties,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${AppLocalizations.of(context)!.distanceKm} ${garage['distance_km'] ?? '?'}',
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.appDiscountLabel((garage['discount_percent'] as int?) ?? 15),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _showDetails(context),
                child: Text(
                  AppLocalizations.of(context)!.viewDetails,
                  style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

