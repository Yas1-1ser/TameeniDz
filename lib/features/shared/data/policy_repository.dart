import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/policy_model.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'audit_repository.dart';
import 'package:tameenidz/core/constants/app_constants.dart';
import 'package:tameenidz/core/services/notification_helper.dart';

final policyRepositoryProvider = Provider<PolicyRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final privilegedClient = ref.watch(privilegedSupabaseProvider);
  return PolicyRepository(client, privilegedClient);
});

class PolicyRepository {
  final SupabaseClient _client;
  final SupabaseClient _privilegedClient;

  PolicyRepository(this._client, this._privilegedClient);

  /// NOTE: The live DB is missing the FK from policies.client_id → users.id,
  /// so PostgREST resource-embedding joins fail with PGRST200.
  /// All read methods use select('*') + _enrichWithClientIfNeeded instead.

  PolicyModel _mapRow(Map<String, dynamic> row) =>
      PolicyModel.fromJson(row);

  Future<PolicyModel> _enrichWithClientIfNeeded(PolicyModel policy) async {
    if (policy.clientId == null) return policy;
    if (policy.clientRegistrationNin != null &&
        policy.clientRegistrationNin!.trim().isNotEmpty) {
      return policy;
    }
    try {
      final user = await _client
          .from('users')
          .select('full_name, phone:phone_number, nin')
          .eq('id', policy.clientId!)
          .maybeSingle();
      if (user == null) return policy;
      return PolicyModel.fromJson({
        ...policy.toJson(),
        'client_registration_nin': user['nin'],
        'applicant_id_number': policy.applicantIdNumber ?? user['nin'],
        'applicant_full_name': policy.applicantFullName ?? user['full_name'],
        'applicant_phone': policy.applicantPhone ?? user['phone'],
      });
    } catch (_) {
      return policy;
    }
  }

  Future<List<PolicyModel>> getPolicies() async {
    final response = await _privilegedClient
        .from('policies')
        .select()
        .order('submitted_at', ascending: false);
    final policies = (response as List).map((json) => _mapRow(json)).toList();
    return Future.wait(policies.map(_enrichWithClientIfNeeded));
  }

  Future<List<PolicyModel>> getPoliciesByOperator(String operatorId) async {
    final response = await _client
        .from('policies')
        .select()
        .eq('operator_id', operatorId)
        .order('submitted_at', ascending: false);
    final policies = (response as List).map((json) => _mapRow(json)).toList();
    return Future.wait(policies.map(_enrichWithClientIfNeeded));
  }

  Future<PolicyModel> getPolicyById(String id) async {
    final response = await _client
        .from('policies')
        .select()
        .eq('id', id)
        .single();
    return _enrichWithClientIfNeeded(_mapRow(response));
  }

  Stream<PolicyModel?> streamPolicyById(String id) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .limit(1)
        .asyncMap((list) async {
          if (list.isEmpty) return null;
          final policy = _mapRow(list.first);
          return _enrichWithClientIfNeeded(policy);
        });
  }

  Future<void> updatePolicyStatus(String id, PolicyStatus status, {String? notes, double? amount}) async {
    final statusStr = PolicyModel.statusToString(status);
    final Map<String, dynamic> updateData = {
      'status': statusStr,
    };

    if (amount != null) {
      updateData['amount'] = amount;
    }

    if (status == PolicyStatus.accepted) {
      updateData['accepted_at'] = DateTime.now().toIso8601String();
    }

    if (notes != null && notes.isNotEmpty) {
      updateData['admin_notes'] = notes;
    }

    await _privilegedClient.from('policies').update(updateData).eq('id', id);

    final policy = await getPolicyById(id);
    final commission = policy.amount * AppConstants.commissionRate;
    try {
      await AuditRepository(_client, _privilegedClient).createLog({
        'action': 'policy_${statusStr}_payment_gateway',
        'user_name': 'Operator Portal',
        'status_color': statusStr,
        'entity_type': 'policy',
        'entity_id': id,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {
          'policy_id': id,
          'client_id': policy.clientId,
          'client_nin': policy.nin,
          'commission_rate': AppConstants.commissionRate,
          'commission_dzd': commission,
          'premium_dzd': policy.amount,
          'portal': 'operator',
        },
      });
    } catch (_) {}

    // ── Notify client about status change ──
    if (policy.clientId != null) {
      NotificationHelper.notifyClientStatusChange(
        clientId: policy.clientId!,
        status: statusStr,
        policyId: id,
        planName: policy.planName,
        privilegedClient: _privilegedClient,
      );
    }
  }

  Future<void> uploadFinalPolicyDocument(String policyId, dynamic fileBytesOrFile, {String fileName = 'policy.pdf'}) async {
    final path = 'policies/$policyId/$fileName';

    if (fileBytesOrFile is List<int>) {
      await _privilegedClient.storage.from('documents').uploadBinary(
        path,
        fileBytesOrFile as dynamic,
        fileOptions: const FileOptions(upsert: true),
      );
    } else {
      await _privilegedClient.storage.from('documents').upload(
        path,
        fileBytesOrFile,
        fileOptions: const FileOptions(upsert: true),
      );
    }

    final url = _privilegedClient.storage.from('documents').getPublicUrl(path);

    final policy = await getPolicyById(policyId);
    final meta = Map<String, dynamic>.from(policy.metadata ?? {});
    meta['final_policy_url'] = url;

    await _privilegedClient.from('policies').update({
      'metadata': meta,
    }).eq('id', policyId);
  }

  Stream<List<PolicyModel>> streamPoliciesByOperator(String operatorId) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('operator_id', operatorId)
        .asyncMap((list) async {
          final policies = list.map((json) => _mapRow(json)).toList();
          return Future.wait(policies.map(_enrichWithClientIfNeeded));
        });
  }

  Stream<List<PolicyModel>> streamAllPolicies() {
    return _privilegedClient
        .from('policies')
        .stream(primaryKey: ['id'])
        .asyncMap((list) async {
          final policies = <PolicyModel>[];
          for (final row in list) {
            policies.add(await _enrichWithClientIfNeeded(_mapRow(row)));
          }
          return policies;
        });
  }

  Stream<List<PolicyModel>> streamPoliciesByUser(String userId) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('client_id', userId)
        .map((list) => list.map((json) => _mapRow(json)).toList());
  }

  Future<PolicyModel> createPolicy(Map<String, dynamic> policyData) async {
    final clientId = policyData['client_id'] as String?;
    if (clientId != null &&
        (policyData['applicant_id_number'] == null ||
            '${policyData['applicant_id_number']}'.trim().isEmpty)) {
      final user = await _client
          .from('users')
          .select('nin, full_name, phone:phone_number')
          .eq('id', clientId)
          .maybeSingle();
      if (user != null) {
        policyData['applicant_id_number'] ??= user['nin'];
        policyData['applicant_full_name'] ??= user['full_name'];
        final meta = Map<String, dynamic>.from(
          policyData['metadata'] as Map<String, dynamic>? ?? {},
        );
        meta['nin'] ??= user['nin'];
        meta['phone'] ??= user['phone'];
        policyData['metadata'] = meta;
      }
    }

    final response = await _privilegedClient
        .from('policies')
        .insert(policyData)
        .select()
        .single();
    final policy = await _enrichWithClientIfNeeded(_mapRow(response));

    // ── Notify operator about new quote/insurance request ──
    String requestType = 'quote';
    if (policy.status == PolicyStatus.insurancePending) {
      requestType = 'insurance';
    }
    NotificationHelper.notifyOperatorNewRequest(
      operatorId: policy.operatorId,
      clientName: policy.applicantFullName ?? policy.applicantName,
      planName: policy.planName ?? 'N/A',
      policyId: policy.id,
      requestType: requestType,
      privilegedClient: _privilegedClient,
    );

    return policy;
  }

  /// Client rejects the operator's accepted offer.
  Future<void> rejectPolicyByClient(String policyId) async {
    const statusStr = 'rejected';
    await _privilegedClient.from('policies').update({
      'status': statusStr,
      'admin_notes': 'Client refused the offer',
    }).eq('id', policyId);

    final policy = await getPolicyById(policyId);

    try {
      await AuditRepository(_client, _privilegedClient).createLog({
        'action': 'policy_rejected_by_client',
        'user_name': policy.applicantFullName ?? 'Client',
        'status_color': statusStr,
        'entity_type': 'policy',
        'entity_id': policyId,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {
          'policy_id': policyId,
          'client_id': policy.clientId,
          'portal': 'client',
        },
      });
    } catch (_) {}

    // Notify operator that client refused the offer
    NotificationHelper.notifyOperatorNewRequest(
      operatorId: policy.operatorId,
      clientName: policy.applicantFullName ?? policy.applicantName,
      planName: policy.planName ?? '',
      policyId: policyId,
      requestType: 'client_refused',
      privilegedClient: _privilegedClient,
    );
  }

  Future<void> updatePolicyPlan(String policyId, Map<String, dynamic> planData) async {
    await _client.from('policies').update(planData).eq('id', policyId);
  }

  Future<void> markPaid(String policyId, String receiptUrl, {String? receiptNumber}) async {
    final statusStr = PolicyModel.statusToString(PolicyStatus.paid);
    final Map<String, dynamic> updateData = {
      'status': statusStr,
      'paid_at': DateTime.now().toIso8601String(),
      'receipt_url': receiptUrl,
    };
    if (receiptNumber != null) {
      updateData['receipt_number'] = receiptNumber;
    }
    await _privilegedClient.from('policies').update(updateData).eq('id', policyId);

    // ── Notify client about successful payment ──
    final policy = await getPolicyById(policyId);
    if (policy.clientId != null) {
      NotificationHelper.notifyClientStatusChange(
        clientId: policy.clientId!,
        status: statusStr,
        policyId: policyId,
        planName: policy.planName,
        privilegedClient: _privilegedClient,
      );
    }
  }

  Future<void> resubmitDocuments(String policyId, List<dynamic> documentUrls) async {
    final statusStr = PolicyModel.statusToString(PolicyStatus.pending);
    await _privilegedClient.from('policies').update({
      'document_urls': documentUrls,
      'status': statusStr,
    }).eq('id', policyId);

    final policy = await getPolicyById(policyId);
    
    // ── Determine the correct request type for the notification ──
    String requestType = 'quote';
    if (policy.status == PolicyStatus.insurancePending ||
        policy.metadata?['request_type'] == 'insurance') {
      requestType = 'insurance';
    }

    // ── Notify operator about updated/resubmitted request ──
    NotificationHelper.notifyOperatorNewRequest(
      operatorId: policy.operatorId,
      clientName: policy.applicantFullName ?? policy.applicantName,
      planName: policy.planName ?? 'N/A',
      policyId: policy.id,
      requestType: requestType,
      privilegedClient: _privilegedClient,
    );
  }
}
