// PATH: lib/features/shared/data/offer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/plan_model.dart';

class OfferRepository {
  final SupabaseClient _client;

  OfferRepository(this._client);

  Stream<List<PlanModel>> streamOffers(String companyEn) {
    final opId = companyEn.toLowerCase().contains('takaful') ? 'algeria_takaful' : 'al_ittihad';
    return _client
        .from('plans')
        .stream(primaryKey: ['id'])
        .eq('operator_id', opId)
        .map((list) => list.map((json) => PlanModel.fromJson(json)).toList());
  }

  Future<void> addOffer(Map<String, dynamic> data) async {
    try {
      await _client.from('plans').insert(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to add offer: ${e.message}');
    }
  }

  Future<void> updateOffer(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('plans').update(data).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update offer: ${e.message}');
    }
  }

  Future<void> deleteOffer(String id) async {
    try {
      await _client.from('plans').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete offer: ${e.message}');
    }
  }
}
