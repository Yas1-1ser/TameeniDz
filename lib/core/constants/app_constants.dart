class AppConstants {
  /// Commission charged to the CLIENT (not the operators): 4.5%
  /// - New client: admin gets 100% of 4.5%
  /// - Existing client re-investing: admin 50%, operator 50%
  static const double commissionRate = 0.045;
  static const double commissionRateAdmin = 0.045;      // new client
  static const double commissionRateAdminSplit = 0.0225; // existing client (50%)
  static const double commissionRateOperatorSplit = 0.0225; // existing client (50%)
}
