import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://zqihvfzxgrfsgbfziwly.supabase.co';
  final serviceRoleKey = 'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW';

  final client = HttpClient();

  try {
    print('Querying OpenAPI spec...');
    final uri = Uri.parse('$url/rest/v1/');
    final request = await client.getUrl(uri);
    request.headers.add('apikey', serviceRoleKey);
    request.headers.add('Authorization', 'Bearer $serviceRoleKey');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final parsed = jsonDecode(body);
      final paths = parsed['paths'] as Map<String, dynamic>;
      print('Exposed Paths/Tables:');
      for (final path in paths.keys) {
        print(' - $path');
      }
      
      final definitions = parsed['definitions'] as Map<String, dynamic>;
      print('\nExposed Definitions:');
      for (final def in definitions.keys) {
        print(' - $def');
      }
    } else {
      print('Error: Status code ${response.statusCode}');
      print('Body: $body');
    }
  } catch (e) {
    print('Failed to inspect: $e');
  } finally {
    client.close();
  }
}
