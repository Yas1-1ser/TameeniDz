class AgentModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? wilaya;
  final double commissionRate;
  final double walletBalance;
  final int totalSalesCount;
  final double totalSalesAmount;
  final bool isActive;
  final DateTime createdAt;

  AgentModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.wilaya,
    this.commissionRate = 10.0,
    this.walletBalance = 0,
    this.totalSalesCount = 0,
    this.totalSalesAmount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      wilaya: json['wilaya'],
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 10.0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      totalSalesCount: json['total_sales_count'] ?? 0,
      totalSalesAmount: (json['total_sales_amount'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'wilaya': wilaya,
      'commission_rate': commissionRate,
      'wallet_balance': walletBalance,
      'total_sales_count': totalSalesCount,
      'total_sales_amount': totalSalesAmount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
