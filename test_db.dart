
import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW'
  );

  try {
    final response = await client.from('policies').insert({
        'client_id':           '00000000-0000-0000-0000-000000000000',
        'plan_id':             'test_plan_id',
        'operator_id':         'TAKAFUL',
        'status':              'insurance_pending',
        'amount':              0,
        'submitted_at':        DateTime.now().toIso8601String(),
        'plan_name':           'test plan',
        'applicant_id_number': '123456',
        'applicant_full_name': 'Test User',
        'document_urls':       [],
        'metadata':            {}
    }).select().single();
    
    print('SUCCESS: ' + response.toString());
  } on PostgrestException catch (e) {
    print('DB ERROR CODE: ' + e.code.toString());
    print('DB ERROR MESSAGE: ' + e.message.toString());
    print('DB ERROR DETAILS: ' + e.details.toString());
  } catch (e) {
    print('OTHER ERROR: ' + e.toString());
  }
}
