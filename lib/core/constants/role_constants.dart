// lib/core/constants/role_constants.dart

class RoleConstants {
  RoleConstants._();

  // User Roles
  static const String admin = 'admin';
  static const String operator = 'operator';
  static const String subscriber = 'subscriber';
  static const String guest = 'guest';

  // Operator Company Codes - Standardized to match App Logic & DB FKs
  static const String companyIttihad = 'al_ittihad';
  static const String companyTakaful = 'algeria_takaful';
}
