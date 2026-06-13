import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW',
  );

  try {
    // Log in as test@test.dz
    final session = await supabase.auth.signInWithPassword(
      email: 'test@test.dz',
      password: 'password123', // Let's try this or another password if we know it
    );
    print('Logged in successfully: user ID = ${session.user?.id}');

    // Query policies
    final policies = await supabase.from('policies').select('*');
    print('Policies found for test@test.dz: ${policies.length}');
    for (var p in policies) {
      print('Policy ID: ${p['id']}, Status: ${p['status']}');
    }
  } catch (e) {
    print('Error during auth/query: $e');
  }
  exit(0);
}
