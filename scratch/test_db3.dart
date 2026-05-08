import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://zqihvfzxgrfsgbfziwly.supabase.co/rest/v1/users';
  final anonKey = 'sb_publishable_SA8pfclEUJxx1n0TNpJVJg_Bo8aomSB';

  // We are trying to insert directly into users to see what constraint fails.
  // We need a random UUID for id, because it's required.
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: jsonEncode({
      'id': '00000000-0000-0000-0000-000000000000',
      'email': 'test@test.com',
      'role': 'client'
    }),
  );

  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
  exit(0);
}
