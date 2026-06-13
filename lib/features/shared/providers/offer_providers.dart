// PATH: lib/features/shared/providers/offer_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/offer_repository.dart';
import '../domain/models/plan_model.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return OfferRepository(client);
});

final offersStreamProvider = StreamProvider.family<List<PlanModel>, String>((ref, companyEn) {
  final repository = ref.watch(offerRepositoryProvider);
  return repository.streamOffers(companyEn);
});
