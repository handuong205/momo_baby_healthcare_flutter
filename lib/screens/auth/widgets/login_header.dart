import 'package:flutter/material.dart';
import '/core/colors/app_colors.dart';


class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 20,
      ),
      child: Column(
        children: [
          // Logo
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Halo
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Logo
              Container(
                width: 76,
                height: 76,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida/AEtjO1WVwWhA_OZqvIk6FKZAioutBFv2lR0p4B58JSQeA7N9siOcfov_G9CSIlOlkWIsO4yU9H0jBPqIpz2YkXWu57LWiEMp-mQJOAqhrwDldoZ6bYlxNdVHd6YX947UvW3-ofsgUF5Io1KsAMleZA55PFcCZyvV2WTfNUKBSOBGHkjzYZqWK3P69oTQl24JpttzSaf4VgqU_qZq_l5I5hohKPyI2abFHURigPg6H_j273uKr9RzXUHwftU4eCk',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 34,
                      );
                    },
                  ),
                ),
              ),

              // Heart
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // MomOi + AI badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MomOi',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.aiPurpleSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.aiPurple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Đồng Hành',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.aiPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Chào mừng Mẹ trở lại! 🌸',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 280,
            ),
            child: Text(
              'Đăng nhập để theo dõi sức khỏe và hành trình lớn khôn của Bé yêu',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}