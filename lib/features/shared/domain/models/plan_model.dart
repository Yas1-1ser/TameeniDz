import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class PlanModel {
  final String id;
  final String planCode; // Human-readable identifier (e.g. 'AUTO_RC', 'AL_RAFIK')
  final String companyName;
  final String companyEn;
  final String operatorId;
  final String premium;
  final String coverage;
  final String tabarruRate;
  final String surplusRate;
  final String claimsDuration;
  final bool isBestValue;
  final String iconType;

  // ── New dynamic catalog fields ──────────────────────────────────────────
  final String descriptionAr;
  final String categoryAr;
  final String badgeAr;
  final String priceNoteAr;
  final String subtitleAr;

  PlanModel({
    required this.id,
    this.planCode = '',
    required this.companyName,
    required this.companyEn,
    required this.operatorId,
    required this.premium,
    required this.coverage,
    required this.tabarruRate,
    required this.surplusRate,
    required this.claimsDuration,
    required this.isBestValue,
    required this.iconType,
    this.descriptionAr = '',
    this.categoryAr = '',
    this.badgeAr = '',
    this.priceNoteAr = '',
    this.subtitleAr = '',
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    // If joined with operators, name_ar/en might be in json['operators']
    final operator = json['operators'] as Map<String, dynamic>?;
    
    return PlanModel(
      id: (json['id'] ?? '').toString(),
      planCode: json['plan_code'] ?? '',
      companyName: operator?['name_ar'] ?? json['name_ar'] ?? '',
      companyEn: operator?['name_en'] ?? json['name_en'] ?? '',
      operatorId: (json['operator_id'] ?? '').toString(),
      premium: "${json['premium_amount'] ?? 0}",
      coverage: json['coverage_details'] ?? '1,000,000',
      tabarruRate: '${((json['tabarru_rate'] ?? 0.0) * 100).toInt()}%',
      surplusRate: '${((json['surplus_rate'] ?? 0.0) * 100).toInt()}%',
      claimsDuration: json['claims_duration'] ?? 'خلال 6 ساعات',
      isBestValue: json['is_best_value'] ?? false,
      iconType: json['icon_type'] ?? 'shield',
      descriptionAr: json['description_ar'] ?? '',
      categoryAr: json['category_ar'] ?? '',
      badgeAr: json['badge_ar'] ?? '',
      priceNoteAr: json['price_note_ar'] ?? '',
      subtitleAr: json['subtitle_ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_code': planCode,
      'name_ar': companyName,
      'name_en': companyEn,
      'premium_amount': double.tryParse(premium.replaceAll(RegExp(r'[^0-9.]'), '')),
      'coverage_details': coverage,
      'tabarru_rate': double.tryParse(tabarruRate.replaceAll('%', '')) != null 
          ? double.parse(tabarruRate.replaceAll('%', '')) / 100 
          : 0.0,
      'surplus_rate': double.tryParse(surplusRate.replaceAll('%', '')) != null 
          ? double.parse(surplusRate.replaceAll('%', '')) / 100 
          : 0.0,
      'claims_duration': claimsDuration,
      'is_best_value': isBestValue,
      'icon_type': iconType,
      'description_ar': descriptionAr,
      'category_ar': categoryAr,
      'badge_ar': badgeAr,
      'price_note_ar': priceNoteAr,
      'subtitle_ar': subtitleAr,
    };
  }

  // Operator getters and helpers used by the UI components
  String get operatorCode => companyEn == "Algerie Takaful" ? "TAKAFUL" : "ITTIHAD";
  String get operatorNameAr => companyName;
  Color get operatorColor => companyEn == "Algerie Takaful" ? const Color(0xFF1E8449) : const Color(0xFF1B4F72);
  
  String getName(String locale) => companyName;

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (planCode.contains('TRAVEL')) return l10n.planTravel;
    if (planCode.contains('DISASTER')) return l10n.planDisaster;
    if (planCode.contains('LIFE')) return l10n.planLife;
    if (planCode.contains('COMPREHENSIVE')) return l10n.planComprehensive;
    if (planCode.contains('PARTIAL')) return l10n.planPartial;
    // Fallback if not matching the predefined keys
    return companyName.isNotEmpty ? planCode : categoryAr;
  }

  String getPriceNote(String locale) => claimsDuration;
  String? getDescription(String locale) => coverage;
  
  double get basePrice => double.tryParse(premium.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

  String get category => coverage.contains("Third") ? "TPL" : "Comprehensive";
  List<String> get documentsRequiredAr => [
    "بطاقة التعريف الوطنية",
    "رخصة السياقة",
    "الرقم التعريفي الجبائي NIF (للمؤسسات)"
  ];

  /// Helper to get the icon from icon_type string
  IconData get resolvedIcon {
    switch (iconType) {
      case 'car':
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'store':
        return Icons.store_rounded;
      case 'build':
        return Icons.build_rounded;
      case 'shipping':
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'flight':
      case 'flight_takeoff':
        return Icons.flight_takeoff_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'business':
      case 'business_center':
        return Icons.business_center_rounded;
      default:
        return Icons.shield_rounded;
    }
  }
}
