import '../../../../shared/enums/policy_status.dart';

class PolicyModel {
  final String id;
  final String? clientId;
  final String planId;
  final String operatorId;
  final PolicyStatus status;
  final double amount;
  final String? companyName;
  final DateTime submittedAt;
  final DateTime? acceptedAt;
  final DateTime? paidAt;
  final String? receiptNumber;
  final List<dynamic>? documentUrls;
  final String? adminNotes;
  final String? applicantIdNumber;
  final String? planName;
  final String? applicantFullName; // To store the fetched name from users table


  PolicyModel({
    required this.id,
    this.clientId,
    required this.planId,
    required this.operatorId,
    required this.status,
    required this.amount,
    this.companyName,
    required this.submittedAt,
    this.acceptedAt,
    this.paidAt,
    this.receiptNumber,
    this.documentUrls,
    this.adminNotes,
    this.applicantIdNumber,
    this.planName,
    this.applicantFullName,
  });

  String get applicantName => applicantFullName ?? 'العميل (${id.substring(0, 5)})';
  String get type => planName ?? planId;

  String get displayCompanyName {
    if (companyName != null && companyName!.isNotEmpty) return companyName!;
    switch (operatorId) {
      case 'algeria_takaful':
        return 'الجزائر للتكافل';
      case 'al_ittihad':
        return 'الاتحاد';
      default:
        return 'غير محدد';
    }
  }

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] ?? '',
      clientId: json['client_id'],
      planId: json['plan_id'] ?? '',
      operatorId: json['operator_id'] ?? '',
      status: _parseStatus(json['status']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      companyName: json['company_name'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      receiptNumber: json['receipt_number'],
      documentUrls: json['document_urls'],
      adminNotes: json['admin_notes'],
      applicantIdNumber: json['applicant_id_number'],
      planName: json['plan_name'],
      applicantFullName: json['applicant_full_name'], // Assuming it might be joined
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'plan_id': planId,
      'operator_id': operatorId,
      'status': statusToString(status),
      'amount': amount,
      'company_name': companyName,
      'submitted_at': submittedAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'receipt_number': receiptNumber,
      'document_urls': documentUrls,
      'admin_notes': adminNotes,
      'applicant_id_number': applicantIdNumber,
      'plan_name': planName,
    };
  }

  static PolicyStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'accepted':
        return PolicyStatus.accepted;
      case 'rejected':
        return PolicyStatus.rejected;
      case 'modificationrequested':
        return PolicyStatus.modificationRequested;
      case 'pending':
      default:
        return PolicyStatus.pending;
    }
  }

  /// Public so [PolicyRepository.updatePolicyStatus] can reuse it.
  static String statusToString(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.accepted:
        return 'accepted';
      case PolicyStatus.rejected:
        return 'rejected';
      case PolicyStatus.modificationRequested:
        return 'modificationRequested';
      case PolicyStatus.pending:
        return 'pending';
    }
  }
}
