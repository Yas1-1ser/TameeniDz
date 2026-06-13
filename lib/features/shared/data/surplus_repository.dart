import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/surplus_model.dart';

final surplusRepositoryProvider = Provider<SurplusRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final privilegedClient = ref.watch(privilegedSupabaseProvider);
  return SurplusRepository(client, privilegedClient);
});

class SurplusRepository {
  final SupabaseClient _client;
  final SupabaseClient _privilegedClient;

  SurplusRepository(this._client, this._privilegedClient);

  Stream<List<SurplusModel>> streamSurplusByOperator(String operatorId) {
    return _client
        .from('surplus_distributions')
        .stream(primaryKey: ['id'])
        .eq('operator_id', operatorId)
        .map((list) => list.map((json) => SurplusModel.fromJson(json)).toList());
  }

  Stream<List<SurplusQuarterModel>> streamQuarterlySurplus(String operatorId) {
    return _client
        .from('surplus_quarters')
        .stream(primaryKey: ['id'])
        .eq('operator_id', operatorId)
        .order('distribution_date', ascending: false)
        .map((list) => list.map((json) => SurplusQuarterModel.fromJson(json)).toList());
  }

  Future<void> createSurplusDistribution(Map<String, dynamic> data) async {
    await _privilegedClient.from('surplus_distributions').insert(data);
  }

  Future<void> updateSurplusStatus(String id, String status) async {
    await _privilegedClient.from('surplus_distributions').update({'status': status}).eq('id', id);
  }
}

