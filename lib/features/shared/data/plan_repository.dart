import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/plan_model.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return PlanRepository(client);
});

class PlanRepository {
  final SupabaseClient _client;

  PlanRepository(this._client);

  Stream<List<PlanModel>> streamPlans() {
    return _client
        .from('plans')
        .stream(primaryKey: ['id'])
        .order('premium', ascending: true)
        .map((list) => list.map((json) => PlanModel.fromJson(json)).toList());
  }
}
