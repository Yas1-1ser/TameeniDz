import 'package:flutter/material.dart';

import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showFooter;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.showFooter = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Removed hardcoded colors to follow theme's appBarTheme
        elevation: 0,
        centerTitle: true,
        actions: [
          if (actions != null) ...actions!,
          const LanguagePickerButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
