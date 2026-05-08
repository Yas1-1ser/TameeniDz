import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/domain/models/policy_model.dart';

final clientPoliciesStreamProvider = StreamProvider.autoDispose<List<PolicyModel>>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);

  return supabase
      .from('policies')
      .stream(primaryKey: ['id'])
      .eq('client_id', userId)
      .order('submitted_at', ascending: false)
      .map((data) => data.map((json) => PolicyModel.fromJson(json)).toList());
});
