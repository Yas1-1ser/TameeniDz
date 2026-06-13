import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/audit_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final privilegedClient = ref.watch(privilegedSupabaseProvider);
  return AuditRepository(client, privilegedClient);
});

class AuditRepository {
  final SupabaseClient _client;
  final SupabaseClient _privilegedClient;

  AuditRepository(this._client, this._privilegedClient);

  Stream<List<AuditModel>> streamAuditLogs() {
    return _client
        .from('audit_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => AuditModel.fromJson(json)).toList());
  }

  Future<void> createLog(Map<String, dynamic> data) async {
    await _privilegedClient.from('audit_logs').insert(data);
  }
}
