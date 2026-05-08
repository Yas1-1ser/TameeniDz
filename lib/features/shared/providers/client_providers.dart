import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/policy_model.dart';
import '../../../../core/providers/service_providers.dart';

final clientPoliciesStreamProvider = StreamProvider<List<PolicyModel>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getClientPolicies();
});
