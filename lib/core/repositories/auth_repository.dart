import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/features/shared/domain/models/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(Supabase.instance.client));

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Current user from Supabase Auth
  User? get currentAuthUser => _client.auth.currentUser;

  /// Fetch full user profile including role-specific metadata
  Future<UserModel?> getCurrentUser() async {
    final authUser = currentAuthUser;
    if (authUser == null) return null;

    try {
      // 1. Get base user data
      final userData = await _client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      final role = userData['role'] as String;
      Map<String, dynamic>? metadata;

      // 2. Get role-specific profile data
      if (role == 'client') {
        metadata = await _client.from('client_profiles').select().eq('id', authUser.id).maybeSingle();
      } else if (role == 'operator') {
        metadata = await _client.from('operator_profiles').select().eq('id', authUser.id).maybeSingle();
      } else if (role == 'admin') {
        metadata = await _client.from('admin_profiles').select().eq('id', authUser.id).maybeSingle();
      }

      return UserModel.fromJson(userData, metadata: metadata);
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
