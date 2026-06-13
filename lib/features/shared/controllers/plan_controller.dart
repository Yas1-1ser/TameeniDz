import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/plan_model.dart';
import '../data/plan_repository.dart';

class PlanState {
  final AsyncValue<List<PlanModel>> plans;
  final bool isSubmitting;
  final String? errorMessage;

  PlanState({
    required this.plans,
    required this.isSubmitting,
    this.errorMessage,
  });

  PlanState copyWith({
    AsyncValue<List<PlanModel>>? plans,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PlanState(
      plans: plans ?? this.plans,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class PlanController extends StateNotifier<PlanState> {
  final PlanRepository _repository;

  PlanController(this._repository)
      : super(PlanState(
          plans: const AsyncValue.loading(),
          isSubmitting: false,
        ));

  Future<void> loadPlans() async {
    state = state.copyWith(plans: const AsyncValue.loading());
    try {
      final data = await _repository.getPlans();
      state = state.copyWith(plans: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(plans: AsyncValue.error(e, st));
    }
  }

  Future<void> addPlan(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.addPlan(data);
      await loadPlans();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.updatePlan(id, data);
      await loadPlans();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  Future<void> deletePlan(String id) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.deletePlan(id);
      await loadPlans();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

final planControllerProvider = StateNotifierProvider<PlanController, PlanState>((ref) {
  return PlanController(ref.watch(planRepositoryProvider));
});
