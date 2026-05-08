import 'package:flutter/material.dart';
import '../../operator/auth/operator_register_screen.dart';

class AtRegisterScreen extends StatelessWidget {
  const AtRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OperatorRegisterScreen(
      preselectedCompany: 'algeria_takaful',
    );
  }
}
