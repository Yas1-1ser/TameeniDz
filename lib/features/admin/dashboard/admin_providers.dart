import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
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
  /// Total premium value of all policies (not count).
  final double totalPremium;
  final double totalCommission;
  final int count;
  final double rate;

  CommissionSummary({
    required this.totalPremium,
    required this.totalCommission,
    required this.count,
    required this.rate,
  });
}

final commissionSummaryProvider =
    Provider.family<CommissionSummary, List<PolicyModel>>((ref, policies) {
  final double rate = AppConstants.commissionRate;
  final totalPremium =
      policies.fold<double>(0.0, (double sum, p) => sum + p.amount);
  return CommissionSummary(
    totalPremium: totalPremium,
    totalCommission: totalPremium * rate,
    count: policies.length,
    rate: rate,
  );
});
