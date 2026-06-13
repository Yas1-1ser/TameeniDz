import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://zqihvfzxgrfsgbfziwly.supabase.co';
  final serviceRoleKey = 'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW';

  final client = HttpClient();

  try {
    print('Inserting policy with select=* using service role...');
    final uri = Uri.parse('$url/rest/v1/policies?select=*');
    final request = await client.postUrl(uri);
    request.headers.add('apikey', serviceRoleKey);
    request.headers.add('Authorization', 'Bearer $serviceRoleKey');
    request.headers.add('Prefer', 'return=representation');
    request.headers.add('Content-Type', 'application/json');

    final bodyStr = jsonEncode({
      'client_id': '00000000-0000-0000-0000-000000000000',
      'plan_id': 'test',
      'operator_id': 'algeria_takaful',
      'amount': 100,
      'status': 'pending',
    });
    
    request.write(bodyStr);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    print('Status: ${response.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Failed: $e');
  } finally {
    client.close();
  }
}
