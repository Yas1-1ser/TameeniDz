import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/policy_model.dart';
import '../../../../shared/enums/policy_status.dart';

final policyRepositoryProvider = Provider<PolicyRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final privilegedClient = ref.watch(privilegedSupabaseProvider);
  return PolicyRepository(client, privilegedClient);
});

class PolicyRepository {
  final SupabaseClient _client;
  final SupabaseClient _privilegedClient;

  PolicyRepository(this._client, this._privilegedClient);

  Future<List<PolicyModel>> getPolicies() async {
    final response = await _client
        .from('policies')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((json) => PolicyModel.fromJson(json)).toList();
  }

  Future<List<PolicyModel>> getPoliciesByOperator(String operatorId) async {
    final response = await _client
        .from('policies')
        .select()
        .eq('operator_id', operatorId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => PolicyModel.fromJson(json)).toList();
  }

  Future<PolicyModel> getPolicyById(String id) async {
    final response =
        await _client.from('policies').select().eq('id', id).single();
    return PolicyModel.fromJson(response);
  }

  Stream<PolicyModel> streamPolicyById(String id) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .limit(1)
        .map((list) => PolicyModel.fromJson(list.first));
  }

  Future<void> updatePolicyStatus(String id, PolicyStatus status, {String? notes}) async {
    final statusStr = PolicyModel.statusToString(status);
    final Map<String, dynamic> updateData = {
      'status': statusStr,
    };
    
    if (status == PolicyStatus.accepted) {
      updateData['accepted_at'] = DateTime.now().toIso8601String();
    }
    
    if (notes != null && notes.isNotEmpty) {
      updateData['admin_notes'] = notes;
    }

    await _privilegedClient
        .from('policies')
        .update(updateData)
        .eq('id', id);
  }

  Stream<List<PolicyModel>> streamPoliciesByOperator(String operatorId) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('operator_id', operatorId)
        .map((list) => list.map((json) => PolicyModel.fromJson(json)).toList());
  }

  Stream<List<PolicyModel>> streamAllPolicies() {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .map((list) => list.map((json) => PolicyModel.fromJson(json)).toList());
  }

  Stream<List<PolicyModel>> streamPoliciesByUser(String userId) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('client_id', userId)
        .map((list) => list.map((json) => PolicyModel.fromJson(json)).toList());
  }

  Future<PolicyModel> createPolicy(Map<String, dynamic> policyData) async {
    final response = await _client
        .from('policies')
        .insert(policyData)
        .select()
        .single();
    return PolicyModel.fromJson(response);
  }
}
