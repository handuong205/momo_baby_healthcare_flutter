import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../state/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool showPassword = false;
  bool agreed = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      await _alert('Thông báo', 'Vui lòng điền đầy đủ các thông tin.');
      return;
    }
    if (password != confirmController.text) {
      await _alert('Lỗi', 'Mật khẩu xác nhận không khớp.');
      return;
    }
    if (password.length < 6) {
      await _alert('Lỗi', 'Mật khẩu phải có độ dài tối thiểu 6 ký tự.');
      return;
    }
    if (!agreed) {
      await _alert(
        'Cần mẹ đồng ý',
        'Mẹ vui lòng đọc và đồng ý với Điều khoản & Chính sách quyền riêng tư để tiếp tục.',
      );
      return;
    }
    final message = await context.read<AuthController>().register(
      email,
      password,
      fullName,
    );
    if (!mounted) return;
    if (message != null || context.read<AuthController>().error == null) {
      await _alert(
        'Chúc mừng!',
        'Đăng ký tài khoản thành công! Hãy đăng nhập.',
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      await _alert(
        'Đăng ký thất bại',
        context.read<AuthController>().error ?? 'Không thể tạo tài khoản.',
      );
    }
  }

  Future<void> _alert(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cream,
                  fixedSize: const Size(40, 40),
                ),
                icon: const Icon(LucideIcons.arrowLeft, size: 20),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tạo tài khoản mới 🌸',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Đồng hành cùng Mom Ơi chăm sóc sức khỏe gia đình trọn vẹn',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.38,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 24),
              if (auth.error != null)
                _RegisterError(message: auth.error!, marginBottom: 16),
              _label('Họ và tên của mẹ'),
              AppTextField(
                controller: fullNameController,
                icon: LucideIcons.user,
                placeholder: 'Nguyễn Thị Mai',
                onChanged: (_) => auth.clearError(),
              ),
              _label('Email'),
              AppTextField(
                controller: emailController,
                icon: LucideIcons.mail,
                placeholder: 'mai.nguyen@example.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => auth.clearError(),
              ),
              _label('Mật khẩu'),
              AppTextField(
                controller: passwordController,
                icon: LucideIcons.lock,
                placeholder: 'Tối thiểu 6 ký tự',
                obscureText: !showPassword,
                onChanged: (_) => auth.clearError(),
                suffix: IconButton(
                  onPressed: () => setState(() => showPassword = !showPassword),
                  icon: Icon(
                    showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ),
              ),
              _label('Xác nhận mật khẩu'),
              AppTextField(
                controller: confirmController,
                icon: LucideIcons.lock,
                placeholder: 'Nhập lại mật khẩu',
                obscureText: !showPassword,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreed,
                    onChanged: (value) =>
                        setState(() => agreed = value ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        children: [
                          const Text(
                            'Tôi đã đọc và đồng ý với ',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.46,
                              color: AppColors.muted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse('https://www.momoi.com.vn/consent'),
                            ),
                            child: const Text(
                              'Điều khoản & Chính sách quyền riêng tư',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.46,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Text(
                            ', đồng ý để Mom Ơi xử lý dữ liệu sức khỏe của tôi và bé nhằm cá nhân hóa gợi ý chăm sóc.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.46,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.6,
                    ),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.control),
                    ),
                    elevation: 4,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          'Hoàn tất đăng ký',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  children: [
                    const Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      ),
    ),
  );
}

class _RegisterError extends StatelessWidget {
  const _RegisterError({required this.message, required this.marginBottom});

  final String message;
  final double marginBottom;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: marginBottom),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.roseLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.rose,
      ),
    ),
  );
}
