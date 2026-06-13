import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRepositoryProvider = Provider((ref) => UserRepository(Supabase.instance.client));

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  /// Fetch client profile data
  Future<Map<String, dynamic>?> getClientProfile(String userId) async {
    return await _client
        .from('client_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  /// Fetch operator profile data
  Future<Map<String, dynamic>?> getOperatorProfile(String userId) async {
    return await _client
        .from('operator_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  /// Fetch admin profile data
  Future<Map<String, dynamic>?> getAdminProfile(String userId) async {
    return await _client
        .from('admin_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  /// Update base user data
  Future<void> updateBaseUser(String userId, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', userId);
  }

  /// Update role-specific profile
  Future<void> updateProfile(String role, String userId, Map<String, dynamic> data) async {
    final table = role == 'client' 
        ? 'client_profiles' 
        : role == 'operator' 
            ? 'operator_profiles' 
            : 'admin_profiles';
            
    await _client.from(table).update(data).eq('id', userId);
  }
}
