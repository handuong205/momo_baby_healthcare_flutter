import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController(
    text: 'me.yeube@gmail.com',
  );

  final _passwordController = TextEditingController(
    text: 'sweetbaby2025',
  );

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('Email: $email');
    debugPrint('Password: $password');

    // TODO:
    // Gọi AuthRepository.login(...)
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          _FieldLabel(
            text: 'Email của Mẹ',
            icon: Icons.star,
          ),

          const SizedBox(height: 4),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: textTheme.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'nhapmail@example.com',
              prefixIcon: Icon(
                Icons.mail,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Password
          _FieldLabel(
            text: 'Mật khẩu',
            icon: Icons.lock,
          ),

          const SizedBox(height: 4),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_open,
                color: AppColors.textSecondary,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Remember + Forgot password
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),

              Expanded(
                child: Text(
                  'Ghi nhớ đăng nhập',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  // TODO: Forgot password
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Quên mật khẩu?',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Login
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _login,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Đăng nhập ngay'),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FieldLabel({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          text,
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          size: 14,
          color: AppColors.primary,
        ),
      ],
    );
  }
}