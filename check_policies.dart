import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW',
  );

  try {
    final res = await supabase.rpc('get_policies_rls'); // Wait, pg_policies doesn't have a direct RPC unless we query it or write a query.
    print(res);
  } catch (e) {
    // Let's try executing a custom query using pg_catalog if possible, or just select from pg_policies.
    // Wait, standard Supabase API doesn't allow raw SQL unless we use RPC.
    // But we can check if RLS is enabled or if there are any errors.
    print('Error: $e');
  }

  // Let's run a select query on pg_policies using public RPC if it exists, or just query public.policies.
  // Wait, let's look at the users table and user IDs.
  final users = await supabase.from('users').select('*');
  print('Total users: ${users.length}');
  for (var u in users) {
    print('User: id=${u['id']}, email=${u['email'] ?? u['email_address']}, name=${u['full_name']}');
  }
  exit(0);
}
