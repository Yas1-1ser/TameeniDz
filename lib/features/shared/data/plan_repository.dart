import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/plan_model.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final privilegedClient = ref.watch(privilegedSupabaseProvider);
  return PlanRepository(client, privilegedClient);
});

class PlanRepository {
  final SupabaseClient _client;
  final SupabaseClient _privilegedClient;

  PlanRepository(this._client, this._privilegedClient);

  Stream<List<PlanModel>> streamPlans() {
    return _client
        .from('plans')
        .stream(primaryKey: ['id'])
        .order('premium_amount', ascending: true)
        .map((list) => list.map((json) => PlanModel.fromJson(json)).toList());
  }

  /// Stream plans filtered by operator_id for the operator portal screens.
  Stream<List<PlanModel>> streamPlansByOperator(String operatorId) {
    return _client
        .from('plans')
        .stream(primaryKey: ['id'])
        .eq('operator_id', operatorId)
        .order('premium_amount', ascending: true)
        .map((list) => list.map((json) => PlanModel.fromJson(json)).toList());
  }

  Future<List<PlanModel>> getPlans() async {
    final response = await _client.from('plans').select().order('premium_amount', ascending: true);
    return (response as List).map((json) => PlanModel.fromJson(json)).toList();
  }

  Future<PlanModel?> getPlanById(String id) async {
    final response = await _client.from('plans').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return PlanModel.fromJson(response);
  }

  Future<PlanModel> addPlan(Map<String, dynamic> data) async {
    final response = await _privilegedClient.from('plans').insert(data).select().single();
    return PlanModel.fromJson(response);
  }

  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    await _privilegedClient.from('plans').update(data).eq('id', id);
  }

  Future<void> deletePlan(String id) async {
    await _privilegedClient.from('plans').delete().eq('id', id);
  }
}

final plansStreamProvider = StreamProvider<List<PlanModel>>((ref) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.streamPlans();
});

/// Filtered stream provider — pass operatorId (e.g. 'algeria_takaful', 'al_ittihad')
final plansByOperatorProvider =
    StreamProvider.family<List<PlanModel>, String>((ref, operatorId) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.streamPlansByOperator(operatorId);
});

final planDetailProvider = FutureProvider.family<PlanModel?, String>((ref, id) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.getPlanById(id);
});
