
import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/baby_info/newborn_profile_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/baby_info/postpartum_info_card.dart';

import '../../core/colors/app_colors.dart';

class PostpartumSetupScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onComplete;

  const PostpartumSetupScreen({
    super.key,
    this.onBack,
    this.onComplete,
  });

  @override
  State<PostpartumSetupScreen> createState() =>
      _PostpartumSetupScreenState();
}

class _PostpartumSetupScreenState
    extends State<PostpartumSetupScreen> {
  bool _isLoading = false;
  bool _isCompleted = false;

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleSubmit() async {
    if (_isLoading || _isCompleted) return;

    setState(() => _isLoading = true);

    // TODO: Gọi API lưu thông tin mẹ và bé tại đây.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isCompleted = true;
    });

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // Chỉ giữ nút Back, không dùng header cũ.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.surface,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _handleBack,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgress(),
                    const SizedBox(height: 20),

                    const PostpartumInfoCard(),
                    const SizedBox(height: 20),

                    const NewbornProfileCard(),
                    const SizedBox(height: 16),

                    _buildAiCard(),
                    const SizedBox(height: 24),

                    _buildBottomSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),   
        ),
        
        const Text(
          'Khởi tạo lộ trình phục hồi cho mẹ & bé',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),

        const SizedBox(height: 4),
        const Text(
          'Hệ thống AI MomOi sẽ chuẩn hóa thực đơn giàu vi chất, '
          'bài tập phục hồi sàn chậu và lịch tiêm chủng phù hợp nhất.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.family_restroom_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Trợ lý AI Bác Sĩ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.aiPurple,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Đồng hành trọn vẹn 365 ngày',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'MomOi sẽ theo sát từng bước ngoặt lớn khôn '
                  'của bé và giấc ngủ của mẹ.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading || _isCompleted
                ? null
                : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted
                  ? AppColors.secondary
                  : AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _isCompleted
                  ? AppColors.secondary
                  : AppColors.primary,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    _isCompleted
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  _isLoading
                      ? 'Đang thiết lập MomOi...'
                      : _isCompleted
                          ? 'Khởi tạo thành công!'
                          : 'Lưu & Khởi tạo lộ trình',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Bạn có thể điều chỉnh lại mọi thông số bất kỳ lúc nào '
          'trong mục Cài đặt.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.calmTeal,
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Dữ liệu y tế được bảo mật an toàn theo tiêu chuẩn HIPAA',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}