import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/domain/models/user_model.dart';
import '../../../shared/data/user_repository.dart';

class UserState {
  final AsyncValue<List<UserModel>> users;
  final bool isSubmitting;
  final String? errorMessage;
  final String searchQuery;

  UserState({
    required this.users,
    required this.isSubmitting,
    this.errorMessage,
    this.searchQuery = '',
  });

  UserState copyWith({
    AsyncValue<List<UserModel>>? users,
    bool? isSubmitting,
    String? errorMessage,
    String? searchQuery,
  }) {
    return UserState(
      users: users ?? this.users,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UserController extends StateNotifier<UserState> {
  final UserRepository _repository;
  List<UserModel> _allUsers = [];

  UserController(this._repository)
      : super(UserState(
          users: const AsyncValue.loading(),
          isSubmitting: false,
        )) {
    _initStream();
  }

  void _initStream() {
    _repository.streamUsers().listen((data) {
      _allUsers = data;
      _applySearch();
    }, onError: (e, st) {
      state = state.copyWith(users: AsyncValue.error(e, st));
    });
  }

  void searchUsers(String query) {
    state = state.copyWith(searchQuery: query);
    _applySearch();
  }

  void _applySearch() {
    if (state.searchQuery.isEmpty) {
      state = state.copyWith(users: AsyncValue.data(_allUsers));
    } else {
      final query = state.searchQuery.toLowerCase();
      final filtered = _allUsers.where((u) {
        return (u.fullName.toLowerCase().contains(query)) ||
               (u.email.toLowerCase().contains(query));
      }).toList();
      state = state.copyWith(users: AsyncValue.data(filtered));
    }
  }

  Future<void> loadUsers() async {
    // Already loaded via stream, but we can reset state if needed
    state = state.copyWith(users: const AsyncValue.loading());
    state = state.copyWith(users: AsyncValue.data(_allUsers));
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.updateUserRole(userId, newRole);
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteUser(String userId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.deleteUser(userId);
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

final userControllerProvider = StateNotifierProvider<UserController, UserState>((ref) {
  return UserController(ref.watch(userRepositoryProvider));
});
