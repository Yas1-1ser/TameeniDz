import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Provides the globally initialized Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides a privileged Supabase client that bypasses RLS (use with caution)
final privilegedSupabaseProvider = Provider<SupabaseClient>((ref) {
  return SupabaseClient(
    SupabaseConstants.url,
    SupabaseConstants.serviceRoleKey,
  );
});
