class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? ccpNumber;
  final String role;
  final String? operatorId;
  final bool documentsSubmitted;
  final DateTime? documentsSubmittedAt;
  final String documentStatus; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.ccpNumber,
    required this.role,
    this.operatorId,
    this.documentsSubmitted = false,
    this.documentsSubmittedAt,
    this.documentStatus = 'pending',
    this.rejectionReason,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? metadata}) {
    final merged = {...json, ...?(metadata)};
    return UserModel(
      id: merged['id'] ?? '',
      fullName: merged['full_name'] ?? 'Unknown User',
      email: merged['email'] ?? '',
      phone: merged['phone_number'] ?? merged['phone'],
      ccpNumber: merged['ccp_number'],
      role: merged['role'] ?? 'client',
      operatorId: merged['operator_id'] ?? merged['company'] ?? merged['employee_id'],
      documentsSubmitted: merged['documents_submitted'] ?? false,
      documentsSubmittedAt: merged['documents_submitted_at'] != null 
          ? DateTime.parse(merged['documents_submitted_at']) 
          : null,
      documentStatus: merged['document_status'] ?? 'pending',
      rejectionReason: merged['rejection_reason'],
      createdAt:
          merged['created_at'] != null
              ? DateTime.parse(merged['created_at'])
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
      'documents_submitted': documentsSubmitted,
      'documents_submitted_at': documentsSubmittedAt?.toIso8601String(),
      'document_status': documentStatus,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? ccpNumber,
    bool? documentsSubmitted,
    DateTime? documentsSubmittedAt,
    String? documentStatus,
    String? rejectionReason,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      ccpNumber: ccpNumber ?? this.ccpNumber,
      role: role,
      operatorId: operatorId,
      documentsSubmitted: documentsSubmitted ?? this.documentsSubmitted,
      documentsSubmittedAt: documentsSubmittedAt ?? this.documentsSubmittedAt,
      documentStatus: documentStatus ?? this.documentStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
    );
  }
}
