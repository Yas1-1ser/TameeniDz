import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/constants/role_constants.dart';

class LoginException implements Exception {
  final String code;
  LoginException(this.code);
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  final SupabaseClient _client = Supabase.instance.client;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _userRole = RoleConstants.guest;
  String get userRole => _userRole;

  String _operatorCode = '';
  String get operatorCode => _operatorCode;

  bool get isLoggedIn => _client.auth.currentSession != null;

  AuthService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final session = _client.auth.currentSession;
    if (session != null) {
      await _fetchUserRole(session.user.id);
    }

    _client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _fetchUserRole(session.user.id);
        // notifyListeners() is called inside _fetchUserRole after role is set
      } else if (event == AuthChangeEvent.signedOut) {
        _userRole = RoleConstants.guest;
        _operatorCode = '';
        notifyListeners();
      }
    });

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> signIn(String email, String password, String role) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userRole = response.user?.userMetadata?['role'] as String?;
      if (userRole != null && role != 'any' && userRole != role) {
        // Optional: you might want to sign out if role doesn't match
      }
    } on AuthException catch (e) {
      throw LoginException(e.code ?? 'auth_unexpected_error');
    } catch (e) {
      throw LoginException('auth_unexpected_error');
    }
  }

  Future<void> _fetchUserRole(String userId) async {
    String tempRole = _userRole;
    String tempOperator = _operatorCode;

    if (tempRole == RoleConstants.guest) {
      final user = _client.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        final meta = user.userMetadata!;
        tempRole = _normalizeRole(meta['role'] as String?);
        tempOperator = _operatorCodeFromCompany(meta['company'] as String?);
      }
    }

    try {
      final profile = await _client.from('users').select('role, company').eq('id', userId).maybeSingle();
      if (profile != null) {
        final dbRole = profile['role'] as String?;
        final dbCompany = profile['company'] as String?;
        tempRole = _normalizeRole(dbRole);
        tempOperator = _operatorCodeFromCompany(dbCompany);

        final currentUser = _client.auth.currentUser;
        if (currentUser != null) {
          final meta = currentUser.userMetadata ?? {};
          final currentMetaRole = meta['role'] as String?;
          final currentMetaCompany = meta['company'] as String?;
          if (currentMetaRole != dbRole || currentMetaCompany != dbCompany) {
            try {
              unawaited(_client.auth.updateUser(UserAttributes(
                data: {
                  ...meta,
                  'role': dbRole,
                  'company': dbCompany,
                },
              )));
            } catch (e) {
              debugPrint('[AuthService] Failed to background-sync DB role to auth metadata: $e');
            }
          }
        }
      } else if (tempRole == RoleConstants.guest) {
        tempRole = RoleConstants.subscriber;
      }
    } catch (e) {
      debugPrint('[AuthService] Error querying user role from DB: $e');
      if (tempRole == RoleConstants.guest) {
        tempRole = RoleConstants.subscriber;
      }
    }

    _userRole = tempRole;
    _operatorCode = tempOperator;
    notifyListeners();
  }

  String _normalizeRole(String? role) {
    if (role == null) return RoleConstants.guest;
    final r = role.toLowerCase();
    if (r == 'admin') return RoleConstants.admin;
    if (r == 'operator' || r == 'employee') return RoleConstants.operator;
    return RoleConstants.subscriber;
  }

  String _operatorCodeFromCompany(String? company) {
    if (company == null) return '';
    final c = company.toLowerCase();
    if (c.contains('algeria_takaful') || c.contains('algeria takaful') || c.contains('الجزائر تكافل')) return RoleConstants.companyTakaful;
    if (c.contains('al-ittihad') || c.contains('al_ittihad') || c.contains('الاتحاد')) return RoleConstants.companyIttihad;
    return '';
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _userRole = RoleConstants.guest;
    _operatorCode = '';
    notifyListeners();
  }

  /// Reload role/company from DB + auth metadata after operator login.
  Future<void> refreshRoleFromSession() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _userRole = RoleConstants.guest;
      _operatorCode = '';
      notifyListeners();
      return;
    }
    await _fetchUserRole(userId);
  }

  /// Ensures router guards see operator context immediately after AT/AI login.
  void applyOperatorSession(String operatorCode) {
    _userRole = RoleConstants.operator;
    _operatorCode = operatorCode;
    notifyListeners();
  }

  String? get sessionCompany =>
      _client.auth.currentUser?.userMetadata?['company'] as String?;
}