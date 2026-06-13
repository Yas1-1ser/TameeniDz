import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://zqihvfzxgrfsgbfziwly.supabase.co';
  final anonKey = 'sb_publishable_OyuJV9L-irGOOtLWRapkzg_S5izLCck';

  final client = HttpClient();

  Future<void> fetch(String endpoint) async {
    print('Querying $endpoint...');
    try {
      final uri = Uri.parse('$url/rest/v1/$endpoint?select=*&order=created_at.desc&limit=10');
      final request = await client.getUrl(uri);
      request.headers.add('apikey', anonKey);
      request.headers.add('Authorization', 'Bearer $anonKey');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final parsed = jsonDecode(body);
        print('--- SUCCESS ($endpoint) ---');
        print(const JsonEncoder.withIndent('  ').convert(parsed));
      } else {
        print('Error ($endpoint): Status code ${response.statusCode}');
        print('Body: $body');
      }
    } catch (e) {
      print('Failed to fetch $endpoint: $e');
    }
  }

  await fetch('users');
  await fetch('error_logs');
  client.close();
}
