import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../domain/models/legal_model.dart';

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return LegalRepository(client);
});

class LegalRepository {
  final SupabaseClient _client;

  LegalRepository(this._client);

  Stream<List<LegalModel>> streamLegalSections() {
    return _client
        .from('legal_sections')
        .stream(primaryKey: ['id'])
        .order('display_order', ascending: true)
        .map((list) => list.map((json) => LegalModel.fromJson(json)).toList());
  }

  Future<String?> getDossierDownloadUrl() async {
    try {
      final String response = await _client.storage
          .from('documents')
          .createSignedUrl('dossier.pdf', 3600);
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Uploads the legal dossier PDF to the 'documents' bucket.
  Future<void> uploadDossierFile(File file) async {
    await _client.storage
        .from('documents')
        .upload(
          'dossier.pdf',
          file,
          fileOptions: const FileOptions(upsert: true, contentType: 'application/pdf'),
        );
  }

  /// Uploads the legal dossier PDF as bytes (for Web support).
  Future<void> uploadDossierBytes(Uint8List bytes) async {
    await _client.storage
        .from('documents')
        .uploadBinary(
          'dossier.pdf',
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'application/pdf'),
        );
  }
}
