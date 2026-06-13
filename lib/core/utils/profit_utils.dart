// lib/core/utils/profit_utils.dart
// Commission: 4.5% taken FROM CLIENT (not operators)
// - New client: admin takes 100% of 4.5%
// - Existing client (re-investment): admin 50%, operator 50%

const double kCommissionRate = 0.045; // 4.5% from client

/// Returns admin commission amount for a given policy.
/// [totalAmount]   — the plan premium in DZD
/// [isExistingClient] — true if client already has a paid policy with this operator
/// Returns: {'admin': double, 'operator': double}
Map<String, double> calculateCommission(
  double totalAmount, {
  required bool isExistingClient,
}) {
  final commission = totalAmount * kCommissionRate;
  if (isExistingClient) {
    return {
      'admin': commission * 0.5,
      'operator': commission * 0.5,
    };
  }
  return {
    'admin': commission,
    'operator': 0.0,
  };
}

/// Legacy helper — total commission amount regardless of split
double totalCommission(double totalAmount) => totalAmount * kCommissionRate;

/// Admin profit (commission) for a policy premium.
/// [rateOverride] replaces [kCommissionRate] when set.
double calculateProfit(
  double premium,
  String operatorCode, {
  double? rateOverride,
}) {
  // operatorCode reserved for per-operator commission splits
  assert(operatorCode.isNotEmpty);
  final rate = rateOverride ?? kCommissionRate;
  return premium * rate;
}

/// Gets the operator display name for the given code.
String operatorDisplayName(String code) {
  switch (code.toUpperCase()) {
    case 'ITTIHAD':
      return 'الجزائر المتحدة';
    case 'TAKAFUL':
    default:
      return 'جزائر تكافل';
  }
}
