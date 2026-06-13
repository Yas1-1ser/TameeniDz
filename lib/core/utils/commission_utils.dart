import 'package:tameenidz/core/constants/app_constants.dart';
import 'package:tameenidz/core/utils/profit_utils.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';

/// Client already has an accepted/paid policy with the same operator (AT/AI).
bool isExistingClientForOperator(PolicyModel policy, List<PolicyModel> allPolicies) {
  final clientId = policy.clientId;
  if (clientId == null || clientId.isEmpty) return false;

  return allPolicies.any((p) {
    if (p.id == policy.id) return false;
    if (p.clientId != clientId) return false;
    if (p.operatorId != policy.operatorId) return false;
    return p.status == PolicyStatus.accepted || p.status == PolicyStatus.paid;
  });
}

/// Platform commission split: new client → 100% admin; returning → 50% admin / 50% operator.
Map<String, double> commissionSplitForPolicy(
  PolicyModel policy,
  List<PolicyModel> allPolicies,
) {
  return calculateCommission(
    policy.amount,
    isExistingClient: isExistingClientForOperator(policy, allPolicies),
  );
}

class PlatformCommissionTotals {
  final double totalPremium;
  final double totalFromClient;
  final double adminShare;
  final double operatorShare;
  final int newClientCount;
  final int returningClientCount;
  final double rate;

  const PlatformCommissionTotals({
    required this.totalPremium,
    required this.totalFromClient,
    required this.adminShare,
    required this.operatorShare,
    required this.newClientCount,
    required this.returningClientCount,
    required this.rate,
  });
}

PlatformCommissionTotals computePlatformCommissions(List<PolicyModel> policies) {
  var admin = 0.0;
  var operator = 0.0;
  var newCount = 0;
  var returning = 0;
  final premium = policies.fold<double>(0, (s, p) => s + p.amount);

  for (final p in policies) {
    final existing = isExistingClientForOperator(p, policies);
    if (existing) {
      returning++;
    } else {
      newCount++;
    }
    final split = calculateCommission(p.amount, isExistingClient: existing);
    admin += split['admin'] ?? 0;
    operator += split['operator'] ?? 0;
  }

  return PlatformCommissionTotals(
    totalPremium: premium,
    totalFromClient: admin + operator,
    adminShare: admin,
    operatorShare: operator,
    newClientCount: newCount,
    returningClientCount: returning,
    rate: AppConstants.commissionRate,
  );
}
