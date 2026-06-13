import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/surplus_repository.dart';
import '../domain/models/surplus_model.dart';
import '../data/policy_repository.dart';
import '../domain/models/policy_model.dart';

final atSurplusStreamProvider = StreamProvider<List<SurplusModel>>((ref) {
  return ref.watch(surplusRepositoryProvider).streamSurplusByOperator('algeria_takaful');
});

final aiSurplusStreamProvider = StreamProvider<List<SurplusModel>>((ref) {
  return ref.watch(surplusRepositoryProvider).streamSurplusByOperator('al_ittihad');
});

final atQuarterlySurplusProvider = StreamProvider<List<SurplusQuarterModel>>((ref) {
  return ref.watch(surplusRepositoryProvider).streamQuarterlySurplus('algeria_takaful');
});

final aiQuarterlySurplusProvider = StreamProvider<List<SurplusQuarterModel>>((ref) {
  return ref.watch(surplusRepositoryProvider).streamQuarterlySurplus('al_ittihad');
});


final atPoliciesStreamProvider = StreamProvider<List<PolicyModel>>((ref) {
  return ref.watch(policyRepositoryProvider).streamPoliciesByOperator('algeria_takaful');
});

final aiPoliciesStreamProvider = StreamProvider<List<PolicyModel>>((ref) {
  return ref.watch(policyRepositoryProvider).streamPoliciesByOperator('al_ittihad');
});

/// FIXED: Explicitly set the provider type to PolicyModel? to allow nullable stream
final policyDetailStreamProvider = StreamProvider.family<PolicyModel?, String>((ref, id) {
  return ref.watch(policyRepositoryProvider).streamPolicyById(id);
});
