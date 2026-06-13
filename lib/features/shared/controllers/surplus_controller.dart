import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/surplus_model.dart';
import '../data/surplus_repository.dart';

class SurplusState {
  final AsyncValue<List<SurplusModel>> surplusDistributions;
  final AsyncValue<List<SurplusQuarterModel>> surplusQuarters;
  final bool isSubmitting;
  final String? errorMessage;

  SurplusState({
    required this.surplusDistributions,
    required this.surplusQuarters,
    required this.isSubmitting,
    this.errorMessage,
  });

  SurplusState copyWith({
    AsyncValue<List<SurplusModel>>? surplusDistributions,
    AsyncValue<List<SurplusQuarterModel>>? surplusQuarters,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return SurplusState(
      surplusDistributions: surplusDistributions ?? this.surplusDistributions,
      surplusQuarters: surplusQuarters ?? this.surplusQuarters,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class SurplusController extends StateNotifier<SurplusState> {
  final SurplusRepository _repository;

  SurplusController(this._repository)
      : super(SurplusState(
          surplusDistributions: const AsyncValue.loading(),
          surplusQuarters: const AsyncValue.loading(),
          isSubmitting: false,
        ));

  void loadSurplusByOperator(String operatorId) {
    state = state.copyWith(surplusDistributions: const AsyncValue.loading());
    _repository.streamSurplusByOperator(operatorId).listen((data) {
      state = state.copyWith(surplusDistributions: AsyncValue.data(data));
    }, onError: (e, st) {
      state = state.copyWith(surplusDistributions: AsyncValue.error(e, st));
    });
  }

  void loadQuarterlySurplus(String operatorId) {
    state = state.copyWith(surplusQuarters: const AsyncValue.loading());
    _repository.streamQuarterlySurplus(operatorId).listen((data) {
      state = state.copyWith(surplusQuarters: AsyncValue.data(data));
    }, onError: (e, st) {
      state = state.copyWith(surplusQuarters: AsyncValue.error(e, st));
    });
  }

  Future<void> distributeSurplus(String operatorId, double amount, List<String> subscriberIds) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final perSubscriberAmount = subscriberIds.isEmpty ? 0 : amount / subscriberIds.length;
      
      for (final subscriberId in subscriberIds) {
        await _repository.createSurplusDistribution({
          'subscriber_name': 'Subscriber $subscriberId', // Ideally fetch from users
          'ccp_number': 'Pending', // Ideally fetch from users
          'amount': perSubscriberAmount,
          'status': 'pending',
          'operator_id': operatorId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

final surplusControllerProvider = StateNotifierProvider<SurplusController, SurplusState>((ref) {
  return SurplusController(ref.watch(surplusRepositoryProvider));
});
