import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final IconData icon;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedLight,
                ),
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}
