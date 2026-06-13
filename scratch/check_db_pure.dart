import 'package:supabase/supabase.dart';

void main() async {
  print('Initializing SupabaseClient...');
  final client = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_publishable_OyuJV9L-irGOOtLWRapkzg_S5izLCck',
  );
  print('SupabaseClient initialized.');

  try {
    print('Testing query from "claims"...');
    final claimsResult = await client.from('claims').select().limit(1);
    print('Query "claims" success! Found: ${claimsResult.length} records.');
    if (claimsResult.isNotEmpty) {
      print('Columns: ${claimsResult.first.keys}');
    }
  } catch (e) {
    print('Query "claims" failed: $e');
  }

  try {
    print('Testing query from "client_claims"...');
    final clientClaimsResult = await client.from('client_claims').select().limit(1);
    print('Query "client_claims" success! Found: ${clientClaimsResult.length} records.');
    if (clientClaimsResult.isNotEmpty) {
      print('Columns: ${clientClaimsResult.first.keys}');
    }
  } catch (e) {
    print('Query "client_claims" failed: $e');
  }
}
