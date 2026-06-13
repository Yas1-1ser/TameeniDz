import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/domain/models/policy_model.dart';

final clientPoliciesStreamProvider = StreamProvider.autoDispose<List<PolicyModel>>((ref) async* {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    yield [];
    return;
  }

  // We use .select() because .stream() requires Realtime to be enabled on the policies table
  final data = await supabase
      .from('policies')
      .select()
      .eq('client_id', userId)
      .order('submitted_at', ascending: false);
      
  yield data.map((json) => PolicyModel.fromJson(json)).toList();
});

final clientPolicyProvider = FutureProvider.family<PolicyModel?, String>((ref, id) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('policies').select().eq('id', id).maybeSingle();
  if (response == null) return null;
  return PolicyModel.fromJson(response);
});
