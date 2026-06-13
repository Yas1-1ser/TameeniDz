import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/audit_model.dart';
import '../data/audit_repository.dart';

class AuditState {
  final AsyncValue<List<AuditModel>> logs;
  final bool isSubmitting;
  final String? errorMessage;

  AuditState({
    required this.logs,
    required this.isSubmitting,
    this.errorMessage,
  });

  AuditState copyWith({
    AsyncValue<List<AuditModel>>? logs,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return AuditState(
      logs: logs ?? this.logs,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class AuditController extends StateNotifier<AuditState> {
  final AuditRepository _repository;

  AuditController(this._repository)
      : super(AuditState(
          logs: const AsyncValue.loading(),
          isSubmitting: false,
        ));

  void loadAuditLogs() {
    state = state.copyWith(logs: const AsyncValue.loading());
    _repository.streamAuditLogs().listen((data) {
      state = state.copyWith(logs: AsyncValue.data(data));
    }, onError: (e, st) {
      state = state.copyWith(logs: AsyncValue.error(e, st));
    });
  }

  Future<void> logAction(String action, String userName, {String? statusColor}) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.createLog({
        'action': action,
        'user_name': userName,
        'status_color': statusColor ?? '#757575',
        'created_at': DateTime.now().toIso8601String(),
      });
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

final auditControllerProvider = StateNotifierProvider<AuditController, AuditState>((ref) {
  return AuditController(ref.watch(auditRepositoryProvider));
});
