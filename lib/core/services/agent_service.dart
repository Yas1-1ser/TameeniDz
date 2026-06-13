import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/features/shared/domain/models/agent_model.dart';
import 'package:tameenidz/features/shared/domain/models/sale_model.dart';

class AgentService {
  final _client = Supabase.instance.client;

  Future<AgentModel> fetchAgentProfile() async {
    final res = await _client
        .from('agents')
        .select()
        .eq('id', _client.auth.currentUser!.id)
        .single();
    return AgentModel.fromJson(res);
  }

  Future<List<SaleModel>> fetchMySales({int limit = 20}) async {
    final res = await _client
        .from('sales')
        .select()
        .eq('agent_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List).map((e) => SaleModel.fromJson(e)).toList();
  }

  Future<void> addSale(SaleModel sale) async {
    final agent = await fetchAgentProfile();
    final commission = sale.totalAmount * (agent.commissionRate / 100);

    await _client.from('sales').insert({
      ...sale.toJson(),
      'agent_id': _client.auth.currentUser!.id,
      'commission_amount': commission,
    });

    await _client.rpc('increment_wallet', params: {
      'agent_id': _client.auth.currentUser!.id,
      'amount': commission,
    });
  }
}
