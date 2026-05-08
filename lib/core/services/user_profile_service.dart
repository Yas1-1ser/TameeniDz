import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService {
  UserProfileService(this._client);

  final SupabaseClient _client;

  Future<void> upsertClientProfile({
    required User user,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String ccpNumber,
    bool phoneVerified = false,
  }) async {
    await _client.from('users').upsert({
      'id': user.id,
      'full_name': fullName,
      'email': email.toLowerCase(),
      'phone_number': phoneNumber,
      'ccp_number': ccpNumber,
      'role': 'client',
      'phone_verified': phoneVerified,
      'email_verified': user.emailConfirmedAt != null,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<void> upsertOperatorProfile({
    required User user,
    required String fullName,
    required String email,
    required String employeeId,
    required String company,
  }) async {
    await _client.from('users').upsert({
      'id': user.id,
      'full_name': fullName,
      'email': email.toLowerCase(),
      'employee_id': employeeId,
      'company': company,
      'role': 'operator',
      'email_verified': user.emailConfirmedAt != null,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<void> markDocumentsSubmitted(String userId) async {
    await _client
        .from('users')
        .update({
          'documents_submitted': true,
          'documents_submitted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }
}
