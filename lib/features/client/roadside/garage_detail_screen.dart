import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/domain/models/garage_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class GarageDetailScreen extends StatelessWidget {
  final GarageModel garage;
  const GarageDetailScreen({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          garage.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──
            _buildHeaderCard(context, l10n, colors)
                .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // ── Info Grid ──
            _buildInfoGrid(context, l10n, colors)
                .animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // ── Services ──
            _buildServicesCard(context, l10n, colors)
                .animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // ── Discount Badge ──
            if (garage.discountPercent > 0)
              _buildDiscountCard(context, l10n, colors)
                  .animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // ── Call Button ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _callGarage(context),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                label: Text(
                  l10n.callDirectlyNow,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppLocalizations l10n, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.car_repair_rounded, color: AppColors.primaryGreen, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garage.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.darkBrown,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (garage.ownerName != null)
                  Text(
                    garage.ownerName!,
                    style: TextStyle(fontSize: 13, color: colors.slate500, fontFamily: 'Cairo'),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < garage.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.goldAccent,
                      size: 18,
                    )),
                    const SizedBox(width: 6),
                    Text(
                      '${garage.rating}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colors.slate700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, AppLocalizations l10n, AppColorsExtension colors) {
    final items = [
      (Icons.location_on_rounded, l10n.province, garage.wilaya, AppColors.primaryGreen),
      (Icons.phone_rounded, l10n.phoneNumber, garage.phone, const Color(0xFF0D47A1)),
      (Icons.build_rounded, l10n.specialty, _specialtyLabel(garage.specialty, l10n), AppColors.goldDeep),
      if (garage.distanceKm != null)
        (Icons.near_me_rounded, l10n.distance, l10n.distanceAway(garage.distanceKm!.toStringAsFixed(1)), AppColors.primaryGreen),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.$4.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.$1, color: item.$4, size: 18),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: TextStyle(fontSize: 11, color: colors.slate500, fontFamily: 'Cairo'),
                    ),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, AppLocalizations l10n, AppColorsExtension colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.servicesOffered,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.darkBrown,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _serviceChip(l10n.specialtyMechanic, Icons.build_rounded),
              if (garage.isTowing)
                _serviceChip(l10n.towingService, Icons.local_shipping_rounded),
              _serviceChip(_specialtyLabel(garage.specialty, l10n), _specialtyIcon(garage.specialty)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard(BuildContext context, AppLocalizations l10n, AppColorsExtension colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldAccent.withValues(alpha: 0.12),
            AppColors.goldAccent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: AppColors.goldDeep, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.partnerDiscount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.goldDeep,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  l10n.discountPercentage(garage.discountPercent.toString()),
                  style: TextStyle(fontSize: 12, color: colors.slate700, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _callGarage(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: garage.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _specialtyLabel(String specialty, AppLocalizations l10n) {
    return switch (specialty) {
      'general' || 'mechanic' => l10n.specialtyMechanic,
      'electrician' || 'electric' => l10n.specialtyElectrician,
      'tires' => l10n.specialtyTires,
      _ => l10n.specialtyDefault,
    };
  }

  IconData _specialtyIcon(String specialty) {
    return switch (specialty) {
      'general' || 'mechanic' => Icons.build_rounded,
      'electrician' || 'electric' => Icons.offline_bolt_rounded,
      'tires' => Icons.tire_repair_rounded,
      _ => Icons.home_repair_service_rounded,
    };
  }
}
