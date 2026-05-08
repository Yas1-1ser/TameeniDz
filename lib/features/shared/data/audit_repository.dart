import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/audit_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return AuditRepository(client);
});

class AuditRepository {
  final SupabaseClient _client;

  AuditRepository(this._client);

  Stream<List<AuditModel>> streamAuditLogs() {
    return _client
        .from('audit_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => AuditModel.fromJson(json)).toList());
  }
}
