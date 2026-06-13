import 'package:tameenidz/features/shared/enums/policy_status.dart';

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
  /// NIN from `users` table (client registration).
  final String? clientRegistrationNin;
  final String? planName;
  final String? applicantFullName;
  final String? applicantPhone;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata; // Dynamic form data

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
    this.clientRegistrationNin,
    this.planName,
    this.applicantFullName,
    this.applicantPhone,
    this.receiptUrl,
    this.metadata,
  });

  String get applicantName => applicantFullName ?? 'Client (${id.substring(0, 5)})';
  String get type => planName ?? planId;

  /// NIN: registration (`users.nin`) first, then policy / quote fields.
  String? get nin {
    final reg = clientRegistrationNin?.trim();
    if (reg != null && reg.isNotEmpty) return reg;
    final col = applicantIdNumber?.trim();
    if (col != null && col.isNotEmpty) return col;
    final meta = metadata?['nin'] as String? ?? metadata?['applicant_nin'] as String?;
    final m = meta?.trim();
    return (m != null && m.isNotEmpty) ? m : null;
  }

  /// Client registration document URLs (stored in metadata when policy is created)
  String? get nationalIdUrl => metadata?['national_id_url'] as String?;
  String? get proofOfAddressUrl => metadata?['proof_of_address_url'] as String?;
  bool get hasClientDocuments => nationalIdUrl != null || proofOfAddressUrl != null;

  /// The finalized issued insurance policy document (uploaded by operator)
  String? get finalPolicyUrl => metadata?['final_policy_url'] as String?;

  String get displayCompanyName {
    if (companyName != null && companyName!.isNotEmpty) return companyName!;
    switch (operatorId) {
      case 'algeria_takaful':
        return 'Algeria Takaful';
      case 'al_ittihad':
        return 'Al-Ittihad';
      default:
        return operatorId;
    }
  }

  /// Merges nested `users` / `client` from Supabase joins into flat policy fields.
  static Map<String, dynamic> mergeClientProfile(Map<String, dynamic> json) {
    final merged = Map<String, dynamic>.from(json);
    final users = json['users'] ?? json['client'];
    if (users is Map<String, dynamic>) {
      merged.remove('users');
      merged.remove('client');
      final nin = users['nin'] as String?;
      final name = users['full_name'] as String?;
      final phone = users['phone'] as String?;
      if (nin != null && nin.toString().trim().isNotEmpty) {
        merged['client_registration_nin'] = nin;
        merged['applicant_id_number'] ??= nin;
      }
      if (name != null && name.toString().trim().isNotEmpty) {
        merged['applicant_full_name'] ??= name;
      }
      if (phone != null && phone.toString().trim().isNotEmpty) {
        merged['applicant_phone'] ??= phone;
      }
    }
    return merged;
  }

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    final flat = mergeClientProfile(json);
    final metadata = flat['metadata'] as Map<String, dynamic>?;
    return PolicyModel(
      id: flat['id'] ?? '',
      clientId: flat['client_id'],
      planId: flat['plan_id'] ?? '',
      operatorId: flat['operator_id'] ?? '',
      status: _parseStatus(flat['status']),
      amount: (flat['amount'] as num?)?.toDouble() ?? 0.0,
      companyName: flat['company_name'] ?? metadata?['company_display'] ?? metadata?['company_name'],
      submittedAt: flat['submitted_at'] != null
          ? DateTime.parse(flat['submitted_at'])
          : DateTime.now(),
      acceptedAt: flat['accepted_at'] != null ? DateTime.parse(flat['accepted_at']) : null,
      paidAt: flat['paid_at'] != null ? DateTime.parse(flat['paid_at']) : null,
      receiptNumber: flat['receipt_number'],
      documentUrls: flat['document_urls'] ?? metadata?['document_urls'],
      adminNotes: flat['admin_notes'],
      applicantIdNumber: flat['applicant_id_number'] ?? metadata?['nin'] ?? metadata?['applicant_id_number'],
      clientRegistrationNin: flat['client_registration_nin'] as String?,
      planName: flat['plan_name'] ?? metadata?['plan_name'],
      applicantFullName: flat['applicant_full_name'] ?? metadata?['full_name'] ?? metadata?['applicant_full_name'],
      applicantPhone: flat['applicant_phone'] ?? metadata?['phone'] ?? metadata?['applicant_phone'],
      receiptUrl: flat['receipt_url'],
      metadata: metadata,
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
      'client_registration_nin': clientRegistrationNin,
      'plan_name': planName,
      'applicant_full_name': applicantFullName,
      'applicant_phone': applicantPhone,
      'receipt_url': receiptUrl,
      'metadata': metadata,
    };
  }

  static PolicyStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'accepted': return PolicyStatus.accepted;
      case 'paid': return PolicyStatus.paid;
      case 'issued': return PolicyStatus.issued;
      case 'rejected': return PolicyStatus.rejected;
      case 'modification_requested':
      case 'modificationrequested': return PolicyStatus.modificationRequested;
      case 'insurance_pending':
      case 'insurancepending': return PolicyStatus.insurancePending;
      case 'pending':
      default: return PolicyStatus.pending;
    }
  }

  static String statusToString(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.accepted: return 'accepted';
      case PolicyStatus.paid: return 'paid';
      case PolicyStatus.issued: return 'issued';
      case PolicyStatus.rejected: return 'rejected';
      case PolicyStatus.modificationRequested: return 'modificationRequested';
      case PolicyStatus.insurancePending: return 'insurance_pending';
      case PolicyStatus.pending: return 'pending';
    }
  }
}
