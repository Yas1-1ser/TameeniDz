
import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW',
  );

  try {
    final policies = await client.from('policies').select('id, operator_id, amount, status');
    print('POLICIES IN DB:');
    for (final p in policies) {
      print('ID: ${p['id']} | Operator: ${p['operator_id']} | Amount: ${p['amount']} | Status: ${p['status']}');
    }
  } catch (e) {
    print('ERROR: $e');
  }
}
