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
      'role': 'client', // Standardized to 'client' to match the database enum type (user_role)
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
    // Build signed URLs for the uploaded documents so operators can view them
    final nationalIdPath = 'users/$userId/documents/national_id';
    final proofPath = 'users/$userId/documents/proof_of_address';

    String? nationalIdUrl;
    String? proofUrl;

    try {
      // Try both common extensions
      for (final ext in ['jpg', 'jpeg', 'png', 'pdf']) {
        try {
          final url = await _client.storage
              .from('documents')
              .createSignedUrl('$nationalIdPath.$ext', 60 * 60 * 24 * 365);
          nationalIdUrl = url;
          break;
        } catch (_) {}
      }
      for (final ext in ['jpg', 'jpeg', 'png', 'pdf']) {
        try {
          final url = await _client.storage
              .from('documents')
              .createSignedUrl('$proofPath.$ext', 60 * 60 * 24 * 365);
          proofUrl = url;
          break;
        } catch (_) {}
      }
    } catch (_) {}

    await _client
        .from('users')
        .update({
          'documents_submitted': true,
          'documents_submitted_at': DateTime.now().toIso8601String(),
          'document_status': 'pending',
          if (nationalIdUrl != null) 'national_id_url': nationalIdUrl,
          if (proofUrl != null) 'proof_of_address_url': proofUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  /// Returns the document storage paths for a given user
  Map<String, String> documentPaths(String userId) => {
    'national_id': 'users/$userId/documents/national_id',
    'proof_of_address': 'users/$userId/documents/proof_of_address',
  };

  Future<void> updateDocumentStatus(String userId, String status, {String? reason}) async {
    await _client
        .from('users')
        .update({
          'document_status': status,
          'rejection_reason': reason,
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
