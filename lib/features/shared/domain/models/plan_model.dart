class PlanModel {
  final String id;
  final String companyName;
  final String companyEn;
  final String premium;
  final String coverage;
  final String tabarruRate;
  final String surplusRate;
  final String claimsDuration;
  final bool isBestValue;
  final String iconType;

  PlanModel({
    required this.id,
    required this.companyName,
    required this.companyEn,
    required this.premium,
    required this.coverage,
    required this.tabarruRate,
    required this.surplusRate,
    required this.claimsDuration,
    required this.isBestValue,
    required this.iconType,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    // If joined with operators, name_ar/en might be in json['operators']
    final operator = json['operators'] as Map<String, dynamic>?;
    
    return PlanModel(
      id: (json['id'] ?? '').toString(),
      companyName: operator?['name_ar'] ?? json['name_ar'] ?? '',
      companyEn: operator?['name_en'] ?? json['name_en'] ?? '',
      premium: "${json['premium_amount'] ?? 0}",
      coverage: json['coverage_details'] ?? '1,000,000',
      tabarruRate: '${((json['tabarru_rate'] ?? 0.0) * 100).toInt()}%',
      surplusRate: '${((json['surplus_rate'] ?? 0.0) * 100).toInt()}%',
      claimsDuration: json['claims_duration'] ?? '48 Hours',
      isBestValue: json['is_best_value'] ?? false,
      iconType: json['icon_type'] ?? 'shield',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}
