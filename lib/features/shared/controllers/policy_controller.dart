import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/policy_model.dart';
import '../../shared/enums/policy_status.dart';
import '../data/policy_repository.dart';
import '../data/audit_repository.dart';

class PolicyState {
  final AsyncValue<List<PolicyModel>> policies;
  final AsyncValue<PolicyModel?> selectedPolicy;
  final bool isSubmitting;
  final String? errorMessage;

  PolicyState({
    required this.policies,
    required this.selectedPolicy,
    required this.isSubmitting,
    this.errorMessage,
  });

  PolicyState copyWith({
    AsyncValue<List<PolicyModel>>? policies,
    AsyncValue<PolicyModel?>? selectedPolicy,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PolicyState(
      policies: policies ?? this.policies,
      selectedPolicy: selectedPolicy ?? this.selectedPolicy,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class PolicyController extends StateNotifier<PolicyState> {
  final PolicyRepository _repository;
  final AuditRepository _auditRepo;

  PolicyController(this._repository, this._auditRepo)
      : super(PolicyState(
          policies: const AsyncValue.loading(),
          selectedPolicy: const AsyncValue.data(null),
          isSubmitting: false,
        ));

  Future<void> loadPolicies() async {
    state = state.copyWith(policies: const AsyncValue.loading());
    try {
      final data = await _repository.getPolicies();
      state = state.copyWith(policies: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(policies: AsyncValue.error(e, st));
    }
  }

  Future<void> loadPoliciesByOperator(String operatorId) async {
    state = state.copyWith(policies: const AsyncValue.loading());
    try {
      final data = await _repository.getPoliciesByOperator(operatorId);
      state = state.copyWith(policies: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(policies: AsyncValue.error(e, st));
    }
  }

  Future<void> loadPoliciesByUser(String userId) async {
    state = state.copyWith(policies: const AsyncValue.loading());
    try {
      // getPoliciesByUser doesn't exist in repo natively, but we can stream it, or we could fetch it here.
    } catch (e, st) {
      state = state.copyWith(policies: AsyncValue.error(e, st));
    }
  }

  Future<void> loadPolicyById(String id) async {
    state = state.copyWith(selectedPolicy: const AsyncValue.loading());
    try {
      final data = await _repository.getPolicyById(id);
      state = state.copyWith(selectedPolicy: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(selectedPolicy: AsyncValue.error(e, st));
    }
  }

  Future<void> updateStatus(String policyId, PolicyStatus status, String userName, {String? notes}) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.updatePolicyStatus(policyId, status, notes: notes);
      
      final statusStr = PolicyModel.statusToString(status);
      await _auditRepo.createLog({
        'action': 'تم تحديث حالة الطلب رقم $policyId إلى $statusStr بواسطة $userName',
        'user_name': userName,
        'status_color': '#4CAF50',
      });
      
      state = state.copyWith(isSubmitting: false);
      await loadPolicyById(policyId); // Refresh selected
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  Future<void> createPolicy(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.createPolicy(data);
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  Future<void> markPaid(String policyId, String receiptUrl, String userName) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.markPaid(policyId, receiptUrl);
      await _auditRepo.createLog({
        'action': 'تم دفع وتأكيد الطلب رقم $policyId بواسطة $userName',
        'user_name': userName,
        'status_color': '#2196F3',
      });
      state = state.copyWith(isSubmitting: false);
      await loadPolicyById(policyId); // Refresh selected
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

final policyControllerProvider = StateNotifierProvider<PolicyController, PolicyState>((ref) {
  return PolicyController(
    ref.watch(policyRepositoryProvider),
    ref.watch(auditRepositoryProvider),
  );
});

final allPoliciesStreamProvider = StreamProvider<List<PolicyModel>>((ref) {
  return ref.watch(policyRepositoryProvider).streamAllPolicies();
});

final operatorPoliciesStreamProvider = StreamProvider.family<List<PolicyModel>, String>((ref, operatorId) {
  return ref.watch(policyRepositoryProvider).streamPoliciesByOperator(operatorId);
});

final userPoliciesStreamProvider = StreamProvider.family<List<PolicyModel>, String>((ref, userId) {
  return ref.watch(policyRepositoryProvider).streamPoliciesByUser(userId);
});

// FIXED: Generic type changed to PolicyModel? to match PolicyRepository.streamPolicyById returning a nullable stream
final policyDetailStreamProvider = StreamProvider.family<PolicyModel?, String>((ref, id) {
  return ref.watch(policyRepositoryProvider).streamPolicyById(id);
});
