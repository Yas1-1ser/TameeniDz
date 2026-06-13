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
      final definitions = parsed['definitions'] as Map<String, dynamic>;
      final policies = definitions['policies'];
      print('Policies table:');
      print(const JsonEncoder.withIndent('  ').convert(policies));
    }
  } catch (e) {
    print('Failed: $e');
  } finally {
    client.close();
  }
}
