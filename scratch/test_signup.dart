import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://zqihvfzxgrfsgbfziwly.supabase.co';
  final anonKey = 'sb_publishable_OyuJV9L-irGOOtLWRapkzg_S5izLCck';

  final client = HttpClient();

  print('Testing signup via Supabase Auth REST API...');
  try {
    final uri = Uri.parse('$url/auth/v1/signup');
    final request = await client.postUrl(uri);
    request.headers.add('apikey', anonKey);
    request.headers.add('Authorization', 'Bearer $anonKey');
    request.headers.contentType = ContentType.json;

    final requestBody = jsonEncode({
      'email': 'test_${DateTime.now().millisecondsSinceEpoch}@taminy.dz',
      'password': 'Password123!',
      'data': {
        'full_name': 'Test User',
        'phone_number': '+2137' + (DateTime.now().millisecondsSinceEpoch % 100000000).toString().padLeft(8, '0'),
        'ccp_number': '1234567',
        'role': 'subscriber',
      }
    });

    request.write(requestBody);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    print('Status code: ${response.statusCode}');
    print('Response body:');
    try {
      final parsed = jsonDecode(body);
      print(const JsonEncoder.withIndent('  ').convert(parsed));
    } catch (_) {
      print(body);
    }
  } catch (e) {
    print('Failed to perform signup: $e');
  } finally {
    client.close();
  }
}
