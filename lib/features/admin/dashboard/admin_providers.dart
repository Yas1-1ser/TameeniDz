import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/core/utils/commission_utils.dart';
import '../../shared/domain/models/policy_model.dart';
import '../../shared/domain/models/audit_model.dart';
import '../../../../core/providers/service_providers.dart';

final allPoliciesStreamProvider = StreamProvider<List<PolicyModel>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamAllPolicies();
});

final auditLogsStreamProvider = StreamProvider<List<AuditModel>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamAuditLogs();
});

class CommissionSummary {
  final double totalPremium;
  /// Total 4.5% charged on client premiums.
  final double totalCommission;
  /// Admin (Tameeni) share — 100% for new clients, 50% for returning.
  final double adminShare;
  /// Operator (AT/AI) share — 0% for new, 50% for returning clients.
  final double operatorShare;
  final int count;
  final int newClientCount;
  final int returningClientCount;
  final double rate;

  CommissionSummary({
    required this.totalPremium,
    required this.totalCommission,
    required this.adminShare,
    required this.operatorShare,
    required this.count,
    required this.newClientCount,
    required this.returningClientCount,
    required this.rate,
  });
}

final commissionSummaryProvider =
    Provider.family<CommissionSummary, List<PolicyModel>>((ref, policies) {
  final totals = computePlatformCommissions(policies);
  return CommissionSummary(
    totalPremium: totals.totalPremium,
    totalCommission: totals.totalFromClient,
    adminShare: totals.adminShare,
    operatorShare: totals.operatorShare,
    count: policies.length,
    newClientCount: totals.newClientCount,
    returningClientCount: totals.returningClientCount,
    rate: totals.rate,
  );
});
