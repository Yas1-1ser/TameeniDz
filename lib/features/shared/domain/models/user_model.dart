class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? ccpNumber;
  final String role;
  final String? operatorId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.ccpNumber,
    required this.role,
    this.operatorId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? json['phone'],
      ccpNumber: json['ccp_number'],
      role: json['role'] ?? 'client',
      operatorId: json['operator_id'] ?? json['company'] ?? json['employee_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phone,
      'ccp_number': ccpNumber,
      'role': role,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
