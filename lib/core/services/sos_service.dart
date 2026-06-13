import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/features/shared/domain/models/garage_model.dart';

class SosService {
  final _supabase = Supabase.instance.client;

  /// Fetch all active garages filtered by wilaya + specialty.
  Future<List<GarageModel>> fetchGarages({
    String? wilaya,
    String? specialty,
  }) async {
    var query = _supabase.from('garages').select().eq('is_active', true);

    if (wilaya != null && wilaya.isNotEmpty && wilaya != 'الكل') {
      query = query.eq('wilaya', wilaya);
    }

    if (specialty != null &&
        specialty.isNotEmpty &&
        specialty != 'mechanic_all') {
      query = query.eq('specialty', specialty);
    }

    final res = await query.order('rating', ascending: false);
    return (res as List).map((e) => GarageModel.fromJson(e)).toList();
  }

  /// Fetch nearest towing trucks (is_towing = true).
  Future<List<GarageModel>> fetchTowingTrucks({String? wilaya}) async {
    var query = _supabase
        .from('garages')
        .select()
        .eq('is_towing', true)
        .eq('is_active', true);

    if (wilaya != null && wilaya.isNotEmpty && wilaya != 'الكل') {
      query = query.eq('wilaya', wilaya);
    }

    final res = await query.order('rating', ascending: false).limit(5);
    return (res as List).map((e) => GarageModel.fromJson(e)).toList();
  }

  /// Fetch all dynamic UI settings.
  Future<Map<String, String>> fetchRoadsideSettings() async {
    try {
      final res = await _supabase.from('roadside_settings').select();
      final map = <String, String>{};
      for (var row in res as List) {
        map[row['key'] as String] = row['value'] as String;
      }
      return map;
    } catch (e) {
      // Return empty map to allow screen code to fallback gracefully to local constants
      return {};
    }
  }
}

