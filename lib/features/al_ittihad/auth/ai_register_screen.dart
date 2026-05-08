import 'package:flutter/material.dart';
import '../../operator/auth/operator_register_screen.dart';

class AiRegisterScreen extends StatelessWidget {
  const AiRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OperatorRegisterScreen(
      preselectedCompany: 'al_ittihad',
    );
  }
}
