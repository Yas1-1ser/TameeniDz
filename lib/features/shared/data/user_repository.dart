import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return UserRepository(client);
});

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

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
    await _client.from('users').update(user.toJson()).eq('id', user.id);
  }

  Future<void> deleteUser(String id) async {
    await _client.from('users').delete().eq('id', id);
  }
}
