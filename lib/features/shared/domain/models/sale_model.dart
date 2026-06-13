class SaleModel {
  final String id;
  final String? agentId;
  final String clientName;
  final String? clientPhone;
  final String? companyName;
  final String policyType;
  final double totalAmount;
  final double? commissionAmount;
  final String status;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    this.agentId,
    required this.clientName,
    this.clientPhone,
    this.companyName,
    required this.policyType,
    required this.totalAmount,
    this.commissionAmount,
    this.status = 'pending',
    required this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      agentId: json['agent_id'],
      clientName: json['client_name'],
      clientPhone: json['client_phone'],
      companyName: json['company_name'],
      policyType: json['policy_type'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num?)?.toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'company_name': companyName,
      'policy_type': policyType,
      'total_amount': totalAmount,
      'commission_amount': commissionAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
