import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW',
  );

  final res = await supabase.from('plans').select().limit(1);
  print(res.first.keys);
}
