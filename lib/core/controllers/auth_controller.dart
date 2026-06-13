import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String userRole;
  final String operatorCode;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.userRole = 'guest',
    this.operatorCode = '',
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? userRole,
    String? operatorCode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userRole: userRole ?? this.userRole,
      operatorCode: operatorCode ?? this.operatorCode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthController(this._authService)
      : super(AuthState(
    isLoggedIn: _authService.isLoggedIn,
    userRole: _authService.userRole,
    operatorCode: _authService.operatorCode,
  )) {
    _authService.addListener(_syncState);
  }

  @override
  void dispose() {
    _authService.removeListener(_syncState);
    super.dispose();
  }

  void _syncState() {
    state = state.copyWith(
      isLoggedIn: _authService.isLoggedIn,
      userRole: _authService.userRole,
      operatorCode: _authService.operatorCode,
      clearError: true,
    );
  }

  Future<void> signIn(String email, String password, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signIn(email, password, role);
      state = state.copyWith(isLoading: false);
    } on LoginException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.code);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'auth_unexpected_error');
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> registerSubscriber({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String ccpNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phone,
          'ccp_number': ccpNumber,
          'role': 'subscriber',
        },
      );

      final user = authResponse.user;
      if (user == null) throw Exception('registration_failed');

      try {
        await _supabase.from('users').upsert({
          'id': user.id,
          'full_name': fullName,
          'email': email,
          'phone_number': phone,
          'ccp_number': ccpNumber,
          'role': 'subscriber',
          'created_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
      } catch (dbErr) {
        debugPrint('Ignored manual upsert error in controller: $dbErr');
      }

      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.code ?? 'auth_unexpected_error');
    } catch (e) {
      final code = e.toString().contains('unexpected_failure')
          ? 'database_error'
          : (e.toString().contains('registration_failed') ? 'registration_failed' : 'auth_unexpected_error');
      state = state.copyWith(isLoading: false, errorMessage: code);
    }
  }

  Future<void> registerOperator({
    required String email,
    required String password,
    required String fullName,
    required String company,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'operator',
          'company': company,
        },
      );

      final user = authResponse.user;
      if (user == null) throw Exception('registration_failed');

      try {
        await _supabase.from('users').upsert({
          'id': user.id,
          'full_name': fullName,
          'email': email,
          'role': 'operator',
          'company': company,
          'created_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
      } catch (dbErr) {
        debugPrint('Ignored manual upsert error in controller: $dbErr');
      }

      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.code ?? 'auth_unexpected_error');
    } catch (e) {
      final code = e.toString().contains('unexpected_failure')
          ? 'database_error'
          : (e.toString().contains('registration_failed') ? 'registration_failed' : 'auth_unexpected_error');
      state = state.copyWith(isLoading: false, errorMessage: code);
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(AuthService.instance);
});