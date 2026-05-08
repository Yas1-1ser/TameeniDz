import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/legal_repository.dart';
import '../../shared/domain/models/legal_model.dart';

final legalSectionsStreamProvider = StreamProvider<List<LegalModel>>((ref) {
  return ref.watch(legalRepositoryProvider).streamLegalSections();
});
