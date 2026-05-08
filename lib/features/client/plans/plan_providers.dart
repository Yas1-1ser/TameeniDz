import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/domain/models/plan_model.dart';
import '../../../../core/providers/service_providers.dart';

final plansProvider = FutureProvider<List<PlanModel>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getPlans();
});
