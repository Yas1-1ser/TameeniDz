import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://zqihvfzxgrfsgbfziwly.supabase.co';
  final serviceRoleKey = 'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW';

  final client = HttpClient();

  try {
    print('Testing query...');
    // We try to reproduce the relationship error
    final uri = Uri.parse('$url/rest/v1/policies?select=*,client_id(*)&limit=1');
    final request = await client.getUrl(uri);
    request.headers.add('apikey', serviceRoleKey);
    request.headers.add('Authorization', 'Bearer $serviceRoleKey');

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
