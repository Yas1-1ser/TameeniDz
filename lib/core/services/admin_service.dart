import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchStats() async {
    final res = await _client.rpc('get_monthly_stats');
    return res as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchAllSales({
    int page = 0,
    int pageSize = 20,
  }) async {
    final res = await _client
        .from('admin_sales_view')
        .select()
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchAllAgents() async {
    final res = await _client
        .from('agents')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateSaleStatus(String saleId, String status) async {
    await _client.from('sales').update({'status': status}).eq('id', saleId);
  }

  Future<List<Map<String, dynamic>>> fetchChartData() async {
    return [
      {'month': 'Jan', 'value': 2400.0},
      {'month': 'Feb', 'value': 3100.0},
      {'month': 'Mar', 'value': 4200.0},
      {'month': 'Apr', 'value': 3800.0},
      {'month': 'May', 'value': 5200.0},
      {'month': 'Jun', 'value': 6100.0},
    ];
  }

  Future<List<Map<String, dynamic>>> fetchCommissions() async {
    final res = await _client
        .from('sales')
        .select('*, agents(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchClaims() async {
    try {
      final res = await _client
          .from('client_claims')
          .select('*, policies(*)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }
}
