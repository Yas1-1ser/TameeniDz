// Static keys — actual values live in l10n ARB files
class AppStrings {
  static const String appName = 'Tameeni Elite';
  static const String ccpMandatory = 'ccp_mandatory_label';
  static const String hardLockMsg = 'payment_hard_lock_message';
  static const String decree2181 = 'decree_21_81_label';
}

/// Platform business constants — change in one place, reflected everywhere.
class AppConstants {
  AppConstants._();

  /// Platform commission rate — defined by Decree 21-81.
  /// Changing this value updates payment_screen, admin_dashboard, and
  /// admin_providers automatically.
  static const double commissionRate = 0.04;
}
