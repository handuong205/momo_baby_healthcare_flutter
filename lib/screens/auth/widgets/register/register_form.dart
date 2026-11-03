import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

import 'register_input.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final bool isAgreed;
  final bool isLoading;

  final ValueChanged<bool> onAgreementChanged;
  final VoidCallback onSubmit;
  final String? fullNameApiError;
  final String? emailApiError;
  final String? passwordApiError;
  const RegisterForm({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isAgreed,
    required this.isLoading,
    required this.onAgreementChanged,
    required this.onSubmit,
    this.fullNameApiError,
    this.emailApiError,
    this.passwordApiError,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================
          // FULL NAME
          // ============================================
          RegisterInput(
            label: 'Họ và tên của Mẹ',
            hint: 'Nguyễn Thị Hoa',
            apiError: widget.fullNameApiError,
            labelIcon: Icons.star,
            prefixIcon: Icons.person,
            controller: widget.fullNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          // ============================================
          // EMAIL
          // ============================================
          RegisterInput(
            label: 'Địa chỉ Email',
            hint: 'email@example.com',
            labelIcon: Icons.star,
            prefixIcon: Icons.mail,
            controller: widget.emailController,
            apiError: widget.emailApiError,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email.';
              }
              if (!value.contains('@')) {
                return 'Email không hợp lệ.';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // ============================================
          // PASSWORD
          // ============================================
          RegisterInput(
            label: 'Mật khẩu',
            hint: '••••••••',
            labelIcon: Icons.star,
            prefixIcon: Icons.lock_open,
            apiError: widget.passwordApiError,
            controller: widget.passwordController,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu.';
              }

              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự.';
              }

              return null;
            },
          ),

          const SizedBox(height: 6),

          // Password hint
          const Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bảo mật với ít nhất 6 ký tự chuẩn y tế',
                  style: TextStyle(fontSize: 11, color: AppColors.secondary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // CONFIRM PASSWORD
          // ============================================
          RegisterInput(
            label: 'Xác nhận mật khẩu',
            hint: 'Nhập lại mật khẩu',
            labelIcon: Icons.star,
            prefixIcon: Icons.lock_open,
            controller: widget.confirmPasswordController,
            obscureText: obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureConfirmPassword = !obscureConfirmPassword;
                });
              },
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textSecondary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu.';
              }

              if (value != widget.passwordController.text) {
                return 'Mật khẩu xác nhận không khớp.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),

          // ============================================
          // AGREEMENT CHECKBOX
          // ============================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onAgreementChanged(!widget.isAgreed);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: widget.isAgreed
                        ? AppColors.primaryContainer
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: widget.isAgreed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'Tôi đồng ý với '),
                      TextSpan(
                        text: 'Điều khoản dịch vụ',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: null,
                      ),
                      const TextSpan(text: ' và '),
                      TextSpan(
                        text: 'Chính sách bảo mật',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' của MomOi'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ============================================
          // SUBMIT BUTTON
          // ============================================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tiếp tục hành trình',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
