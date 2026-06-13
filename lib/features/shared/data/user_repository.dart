import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import 'package:tameenidz/features/shared/domain/models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final privilegedClient = ref.watch(privilegedSupabaseProvider);
  return UserRepository(client, privilegedClient);
});

class UserRepository {
  final SupabaseClient _client;
  final SupabaseClient _privilegedClient;

  UserRepository(this._client, this._privilegedClient);

  Stream<List<UserModel>> streamUsers() {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => UserModel.fromJson(json)).toList());
  }

  Future<void> createUser(UserModel user) async {
    await _client.from('users').insert(user.toJson());
  }

  Future<void> updateUser(UserModel user) async {
    final payload = user.toJson();
    payload.remove('id');
    payload.remove('created_at');
    payload.remove('email');
    payload.remove('role');
    
    await _privilegedClient.from('users').update(payload).eq('id', user.id);

    try {
      if (user.role == 'client') {
        await _privilegedClient.from('client_profiles').update({
          'full_name': user.fullName,
          'phone_number': user.phone,
          'ccp_number': user.ccpNumber,
        }).eq('id', user.id);
      } else if (user.role == 'operator' || user.role == 'employee') {
        await _privilegedClient.from('operator_profiles').update({
          'full_name': user.fullName,
        }).eq('id', user.id);
      }
    } catch (e) {
      print('Profile sync note: $e');
    }
  }

  Future<UserModel> getUserById(String id) async {
    final response = await _client.from('users').select().eq('id', id).single();
    return UserModel.fromJson(response);
  }

  Future<void> updateUserRole(String id, String role) async {
    await _privilegedClient.from('users').update({'role': role}).eq('id', id);
  }

  /// Deletes a user. If [force] is true, it manually cleans up all related records.
  Future<void> deleteUser(String id, {bool force = false}) async {
    if (force) {
      try {
        await _privilegedClient.from('operator_legal_log').delete().or('operator_id.eq.$id,related_client_id.eq.$id');
        await _privilegedClient.from('client_claims').delete().or('client_id.eq.$id,operator_id.eq.$id');
        await _privilegedClient.from('client_road_assistance').delete().eq('client_id', id);
        await _privilegedClient.from('client_policies').delete().eq('client_id', id);
        await _privilegedClient.from('policies').delete().eq('client_id', id);
        await _privilegedClient.from('client_documents').delete().eq('client_id', id);
        await _privilegedClient.from('admin_notifications').delete().or('target_user_id.eq.$id,created_by.eq.$id');
        await _privilegedClient.from('admin_user_actions').delete().or('target_user_id.eq.$id,admin_id.eq.$id');
        await _privilegedClient.from('admin_settings').delete().eq('updated_by', id);
        await _privilegedClient.from('client_profiles').delete().eq('id', id);
        await _privilegedClient.from('operator_profiles').delete().eq('id', id);
        await _privilegedClient.from('admin_profiles').delete().eq('id', id);
      } catch (e) {
        print('Force delete cleanup note: $e');
      }
    }

    try {
      await _privilegedClient.auth.admin.deleteUser(id);
    } catch (e) {
      await _privilegedClient.from('users').delete().eq('id', id);
    }
  }

  /// USE WITH EXTREME CAUTION: Wipes all system data except admin users.
  Future<void> wipeSystemData() async {
    final tables = [
      'client_claims',
      'client_policies',
      'policies',
      'admin_notifications',
      'admin_user_actions',
      'audit_logs',
      'operator_legal_log',
      'client_road_assistance',
      'surplus_distributions',
      'error_logs',
      'client_documents'
    ];

    for (var table in tables) {
      try {
        // Use a filter that always matches all rows to perform a table-wide delete
        // Supabase/Postgrest requires a filter for delete unless specifically allowed.
        await _privilegedClient.from(table).delete().neq('id', '00000000-0000-0000-0000-000000000000');
      } catch (e) {
        print('Wipe error on $table: $e');
      }
    }

    // Delete all non-admin users from public profiles then Auth
    try {
      final List users = await _privilegedClient
          .from('users')
          .select('id')
          .neq('role', 'admin');

      for (var u in users) {
        final userId = u['id'];
        try {
          await _privilegedClient.auth.admin.deleteUser(userId);
        } catch (e) {
          await _privilegedClient.from('users').delete().eq('id', userId);
        }
      }
    } catch (e) {
      print('Wipe users error: $e');
    }
  }
}
