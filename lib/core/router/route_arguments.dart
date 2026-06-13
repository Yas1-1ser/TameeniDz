// lib/core/router/route_arguments.dart
import '../../features/shared/domain/models/plan_model.dart';

class PlanDetailArgs {
  final PlanModel plan;
  const PlanDetailArgs({required this.plan});
}

class QuoteFormArgs {
  final PlanModel plan;
  
  const QuoteFormArgs({
    required this.plan,
  });
}

class QuoteResultArgs {
  final double calculatedPremium;
  final Map<String, dynamic> formData;
  final String planName;
  final String operatorCode;
  
  const QuoteResultArgs({
    required this.calculatedPremium,
    required this.formData,
    required this.planName,
    required this.operatorCode,
  });
}

class PolicyDetailArgs {
  final String policyId;
  const PolicyDetailArgs({required this.policyId});
}

class ClaimDetailArgs {
  final String claimId;
  const ClaimDetailArgs({required this.claimId});
}

class GarageDetailArgs {
  final String garageId;
  const GarageDetailArgs({required this.garageId});
}

class AdminUserDetailArgs {
  final String userId;
  const AdminUserDetailArgs({required this.userId});
}

class OperatorPoliciesArgs {
  final String operatorCode;
  const OperatorPoliciesArgs({required this.operatorCode});
}

class OperatorClaimsArgs {
  final String operatorCode;
  const OperatorClaimsArgs({required this.operatorCode});
}

class OtpVerificationArgs {
  final String verificationId;
  final String phoneNumber;
  final bool isRegistration;
  final String? email;
  final String? fullName;
  final String? ccpNumber;
  final String? nin;
  final String? wilaya;
  final String? dob;

  const OtpVerificationArgs({
    required this.verificationId,
    required this.phoneNumber,
    this.isRegistration = false,
    this.email,
    this.fullName,
    this.ccpNumber,
    this.nin,
    this.wilaya,
    this.dob,
  });
}

class RegisterStep2Args {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String ccpNumber;
  final String? nin;
  final String? wilaya;
  final String? dob;

  RegisterStep2Args({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.ccpNumber,
    this.nin,
    this.wilaya,
    this.dob,
  });
}

class NewClaimArgs {
  final String? policyId;
  const NewClaimArgs({this.policyId});
}

class LoginArgs {
  final String? role;
  final String? company;
  const LoginArgs({this.role, this.company});
}
