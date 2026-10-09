import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class RegisterInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData labelIcon;
  final IconData prefixIcon;

  final TextEditingController controller;

  final TextInputType? keyboardType;
  final bool obscureText;

  final Widget? suffixIcon;

  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final String? apiError;

  const RegisterInput({
    super.key,
    required this.label,
    required this.hint,
    required this.labelIcon,
    required this.prefixIcon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.apiError,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label giống LoginForm
        Row(
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(labelIcon, size: 14, color: AppColors.primary),
          ],
        ),

        const SizedBox(height: 4),

        // Input giống LoginForm
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          forceErrorText: apiError,
          validator: validator,
          onChanged: onChanged,
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: AppColors.primary),
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
