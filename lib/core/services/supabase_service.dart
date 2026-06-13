import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/shared/domain/models/plan_model.dart';
import '../../features/shared/domain/models/policy_model.dart';
import '../../features/shared/domain/models/audit_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Auth & User Sync ---

  /// Verifies a user in Supabase by their phone number after Firebase validation.
  /// This performs a manual upsert into the 'public.users' table.
  Future<void> syncUserAfterPhoneAuth({
    required String phoneNumber,
    String? fullName,
  }) async {
    // Ensure the phone number is formatted correctly (+213XXXXXXXXX)
    final formattedPhone =
        phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

    final payload = {
      'phone_number': formattedPhone,
      if (fullName != null) 'full_name': fullName,
      'phone_verified': true,
      'last_login': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('users').upsert({
        'id': userId,
        ...payload,
      }, onConflict: 'id');
      return;
    }

    await _client
        .from('users')
        .update(payload)
        .eq('phone_number', formattedPhone);
  }

  /// Note: We rely on Firebase for Phone OTP.
  /// Supabase Auth is used for session management if a custom JWT bridging is implemented.

  Future<void> signOut() async {
    // Sign out from Supabase
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // --- Plans ---



  // --- Policies ---

  Future<void> submitPolicy({
    required String planId,
    required String operatorId,
    required double amount,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('policies').insert({
      'client_id': userId,
      'plan_id': planId,
      'operator_id': operatorId,
      'amount': amount,
      'status': 'pending',
    });
  }

  Stream<List<PolicyModel>> getClientPolicies() {
    final userId = currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('client_id', userId)
        .order('submitted_at')
        .map((data) => data.map((json) => PolicyModel.fromJson(json)).toList());
  }

  // --- Admin ---

  Future<List<PlanModel>> getPlans() async {
    // FIXED: wrapped in try/catch — if the 'operators' FK or table is missing,
    // PostgREST returns a 400; fall back to a plain select so the screen doesn't crash.
    try {
      final response = await _client
          .from('plans')
          .select('*, operators(name_ar, name_en)')
          .order('premium_amount', ascending: true);
      return (response as List).map((json) => PlanModel.fromJson(json)).toList();
    } on PostgrestException catch (_) {
      // FIXED: fallback – fetch without join if operators table/FK not configured
      final response = await _client
          .from('plans')
          .select()
          .order('premium_amount', ascending: true);
      return (response as List).map((json) => PlanModel.fromJson(json)).toList();
    }
  }

  Stream<List<PolicyModel>> streamAllPolicies() {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .order('submitted_at')
        .map((data) => data.map((json) => PolicyModel.fromJson(json)).toList());
  }

  Stream<List<AuditModel>> streamAuditLogs() {
    return _client
        .from('audit_logs')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => AuditModel.fromJson(json)).toList());
  }
}
