import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoggerService {
  final SupabaseClient _client;

  LoggerService(this._client);

  /// Logs an error to the Supabase error_logs table.
  Future<void> logError({
    required String message,
    String? errorCode,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      await _client.from('error_logs').insert({
        'user_id': userId,
        'error_message': message,
        'error_code': errorCode,
        'stack_trace': stackTrace,
        'context_data': context,
      });
      
      debugPrint('Logged error to Supabase: $message');
    } catch (e) {
      // If logging itself fails, just print to console to avoid infinite loop
      debugPrint('Failed to log error to Supabase: $e');
    }
  }
}
