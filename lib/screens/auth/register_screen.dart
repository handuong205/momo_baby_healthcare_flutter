import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/models/auth/register_request.dart';
import 'package:momo_baby_healthcare_flutter/repositories/auth/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/widgets/register/register_form.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/widgets/register/register_security.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/journey_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isAgreed = false;
  bool isLoading = false;

  String? emailApiError;
  String? fullNameApiError;
  String? passwordApiError;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Hiển thị dialog thông báo đăng ký thành công
  Future<void> register() async {
    // 1. Kiểm tra dữ liệu form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // 2. Kiểm tra đồng ý điều khoản
    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng đồng ý với điều khoản và chính sách bảo mật.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Hiển thị loading
    setState(() {
      isLoading = true;
    });

    try {
      // 4. Gọi API đăng ký thật
      await AuthRepository.register(
        RegisterRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
          fullName: fullNameController.text.trim(),
        ),
      );

      if (!mounted) return;

      // 5. Tắt loading
      setState(() {
        isLoading = false;
      });

      // 6. Thông báo đăng ký thành công
      await _showRegisterSuccessDialog();

      if (!mounted) return;

      // 7. Chuyển sang màn hình chọn hành trình
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JourneySelectionScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;

        // Xóa lỗi cũ trước khi xử lý lỗi mới
        fullNameApiError = null;
        emailApiError = null;
        passwordApiError = null;
      });

      final message = e.message.toLowerCase();

      if (message.contains('email')) {
        setState(() {
          emailApiError = e.message;
        });
      } else if (message.contains('password') || message.contains('mật khẩu')) {
        setState(() {
          passwordApiError = e.message;
        });
      } else if (message.contains('fullname') ||
          message.contains('full name') ||
          message.contains('họ và tên')) {
        setState(() {
          fullNameApiError = e.message;
        });
      } else {
        // Lỗi không xác định được input tương ứng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
  }

  Future<void> _showRegisterSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.secondary,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(child: Text('Đăng ký thành công 🎉')),
            ],
          ),
          content: const Text(
            'Tài khoản của Mẹ đã được tạo thành công.\n\n'
            'Vui lòng chọn giai đoạn hiện tại của Mẹ '
            'để MomOi có thể cá nhân hóa trải nghiệm phù hợp.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryLight,

      // SafeArea giúp tránh status bar / tai thỏ / camera cutout.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // HEADER
                // ============================================

                Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.onSurface,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        'An toàn & Y tế',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ============================================
                // LOGO / ICON
                // ============================================
                Center(
                  child: Column(
                    children: [
                      const Text('🌸', style: TextStyle(fontSize: 56)),

                      const SizedBox(height: 8),

                      Text(
                        'Chào mừng Mẹ đến với MomOi',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Tạo tài khoản để bắt đầu hành trình '
                        'chăm sóc sức khỏe cùng MomOi.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // REGISTER FORM
                // ============================================
                RegisterForm(
                  fullNameController: fullNameController,
                  emailController: emailController,
                  passwordController: passwordController,
                  fullNameApiError: fullNameApiError,
                  emailApiError: emailApiError,
                  passwordApiError: passwordApiError,
                  confirmPasswordController: confirmPasswordController,
                  isAgreed: isAgreed,
                  isLoading: isLoading,
                  onAgreementChanged: (value) {
                    setState(() {
                      isAgreed = value;
                    });
                  },
                  onSubmit: register,
                ),

                const SizedBox(height: 20),

                // ============================================
                // LOGIN
                // ============================================
                Center(
                  child: TextButton(
                    onPressed: _goBack,
                    child: const Text('Đã có tài khoản? Đăng nhập ngay'),
                  ),
                ),

                const SizedBox(height: 8),

                // ============================================
                // SECURITY
                // ============================================
                const RegisterSecurity(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
