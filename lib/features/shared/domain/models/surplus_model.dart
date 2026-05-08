class SurplusModel {
  final String id;
  final String subscriberName;
  final String ccpNumber;
  final double amount;
  final String status;
  final String operatorId;
  final DateTime createdAt;

  SurplusModel({
    required this.id,
    required this.subscriberName,
    required this.ccpNumber,
    required this.amount,
    required this.status,
    required this.operatorId,
    required this.createdAt,
  });

  factory SurplusModel.fromJson(Map<String, dynamic> json) {
    return SurplusModel(
      id: json['id'] ?? '',
      subscriberName: json['subscriber_name'] ?? 'Subscriber',
      ccpNumber: json['ccp_number'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      operatorId: json['operator_id'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriber_name': subscriberName,
      'ccp_number': ccpNumber,
      'amount': amount,
      'status': status,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SurplusQuarterModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String status;
  final double policyholdersFund;
  final double shareholdersFund;
  final double individualShare;
  final DateTime distributionDate;
  final String operatorId;

  SurplusQuarterModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.status,
    required this.policyholdersFund,
    required this.shareholdersFund,
    required this.individualShare,
    required this.distributionDate,
    required this.operatorId,
  });

  factory SurplusQuarterModel.fromJson(Map<String, dynamic> json) {
    return SurplusQuarterModel(
      id: json['id'] ?? '',
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      status: json['status'] ?? 'pending',
      policyholdersFund: (json['policyholders_fund'] as num?)?.toDouble() ?? 0.0,
      shareholdersFund: (json['shareholders_fund'] as num?)?.toDouble() ?? 0.0,
      individualShare: (json['individual_share'] as num?)?.toDouble() ?? 0.0,
      distributionDate: json['distribution_date'] != null 
          ? DateTime.parse(json['distribution_date']) 
          : DateTime.now(),
      operatorId: json['operator_id'] ?? '',
    );
  }
}

