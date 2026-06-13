import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Provides the globally initialized Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides a privileged Supabase client that bypasses RLS (use with caution)
/// 
/// ⚠️ SECURITY WARNING: This provider uses the service_role key.
/// In a production environment, this key MUST NOT be included in the client application.
/// Administrative operations should be moved to Supabase Edge Functions, and this
/// provider should be removed from the frontend binary to prevent data exposure.
final privilegedSupabaseProvider = Provider<SupabaseClient>((ref) {
  final client = SupabaseClient(
    SupabaseConstants.url,
    SupabaseConstants.serviceRoleKey,
    authOptions: const AuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );
  
  // FIXED: Keep this provider alive or manage carefully to avoid connection thrashing
  // if used in many auto-dispose contexts.
  ref.onDispose(client.dispose);
  return client;
});
