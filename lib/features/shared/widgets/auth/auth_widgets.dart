import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool? obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.obscureText,
    this.onToggleVisibility,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.darkText,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText ?? isPassword,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(color: context.colors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.slate500, fontSize: 14),
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, color: AppColors.goldAccent)
                    : null,
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        (obscureText ?? true)
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.colors.slate500,
                      ),
                      onPressed: onToggleVisibility,
                    )
                    : null,
            filled: true,
            fillColor: context.colors.offWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.goldAccent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.rejected),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.rejected,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryGreen,
          foregroundColor: foregroundColor ?? context.colors.offWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.offWhite,
                    ),
                  ),
                )
                : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
