import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/repositories/user/user_profile.repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/postpartum_setup_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/pregnancy_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/mom_journey/journey_bottom_action.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/mom_journey/journey_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/mom_journey/journey_header.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/mom_journey/journey_trust_banner.dart';

import 'package:momo_baby_healthcare_flutter/screens/information/pre_pregnancy_screen.dart';

enum PregnancyStage {
  prePregnancy('Chuẩn bị mang thai'),
  pregnancy('Đang mang thai'),
  postpartum('Bé đã chào đời');

  const PregnancyStage(this.label);

  final String label;
}

class JourneySelectionScreen extends StatefulWidget {
  /// Lộ trình mẹ đang theo dõi. Khác `null` khi mở lại từ trang chủ:
  /// hiện nút back, chọn sẵn lộ trình này và hỏi xác nhận trước khi đổi.
  final PregnancyStage? currentStage;

  const JourneySelectionScreen({super.key, this.currentStage});

  @override
  State<JourneySelectionScreen> createState() => _JourneySelectionScreenState();
}

class _JourneySelectionScreenState extends State<JourneySelectionScreen> {
  late PregnancyStage _selectedStage =
      widget.currentStage ?? PregnancyStage.prePregnancy;

  bool get _isChanging => widget.currentStage != null;

  final TextEditingController _nicknameController = TextEditingController(
    text: 'Bé Bắp',
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _selectStage(PregnancyStage stage) {
    setState(() {
      _selectedStage = stage;
    });
  }

  Future<bool> _confirmChange() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Thay đổi lộ trình?'),
        content: Text(
          'Mẹ có chắc muốn chuyển từ "${widget.currentStage!.label}" '
          'sang "${_selectedStage.label}" không?\n\n'
          'MomOi sẽ cập nhật lại thực đơn, lời khuyên và lộ trình theo giai đoạn mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
            child: const Text('Thay đổi'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _continue() async {
  if (_isLoading) return;

  if (_isChanging) {
    // Vẫn giữ lộ trình cũ thì không cần đổi.
    if (_selectedStage == widget.currentStage) return;
    if (!await _confirmChange() || !mounted) return;
  }

  final stage = switch (_selectedStage) {
    PregnancyStage.prePregnancy => 'PrePregnancy',
    PregnancyStage.pregnancy => 'Pregnant',
    PregnancyStage.postpartum => 'Postpartum',
  };

  setState(() {
    _isLoading = true;
  });

  try {
    await UserProfileRepository.chooseStageUserProfile(stage);

    if (!mounted) return;

    Widget nextScreen;

    switch (_selectedStage) {
      case PregnancyStage.prePregnancy:
        nextScreen = const PrePregnancyScreen();
        break;

      case PregnancyStage.pregnancy:
        nextScreen = const PregnancyScreen();
        break;

      case PregnancyStage.postpartum:
        nextScreen = const PostpartumSetupScreen();
        break;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  } on ApiException catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ApiError.getErrorMessage(e)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ApiError.getErrorMessage(e)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    if (_isChanging)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Quay lại',
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.onSurface,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 8),

                    JourneyHeader(isChanging: _isChanging),

                    const SizedBox(height: 20),

                    // =========================
                    // PRE-PREGNANCY
                    // =========================
                    JourneyCard(
                      stage: PregnancyStage.prePregnancy,
                      selectedStage: _selectedStage,
                      isCurrent: widget.currentStage == PregnancyStage.prePregnancy,
                      emoji: '🌸',
                      title: 'Chuẩn bị mang thai',
                      description: 'Theo dõi chu kỳ kinh nguyệt, tính ngày rụng trứng tối ưu để sẵn sàng đón tin vui.',
                      isDisabled: _isLoading,
                      onTap: () {
                        _selectStage(PregnancyStage.prePregnancy);
                      },
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // PREGNANCY
                    // =========================
                    JourneyCard(
                      stage: PregnancyStage.pregnancy,
                      selectedStage: _selectedStage,
                      isCurrent: widget.currentStage == PregnancyStage.pregnancy,
                      emoji: '🤰',
                      title: 'Đang mang thai',
                      description: 'Đồng hành theo dõi tuần thai, dinh dưỡng mẹ bầu và chuẩn bị sinh trọn gói.',
                      isDisabled: _isLoading,
                      popular: true,
                      onTap: () {
                        _selectStage(PregnancyStage.pregnancy);
                      },
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // POSTPARTUM
                    // =========================
                    JourneyCard(
                      stage: PregnancyStage.postpartum,
                      selectedStage: _selectedStage,
                      isCurrent: widget.currentStage == PregnancyStage.postpartum,
                      emoji: '👶',
                      title: 'Bé đã chào đời',
                      description: 'Theo dõi cân nặng, chiều cao WHO, cữ bú, giấc ngủ và thực đơn ăn dặm cho bé.',
                      isDisabled: _isLoading,
                      nicknameController: _nicknameController,
                      onTap: () {
                        _selectStage(PregnancyStage.postpartum);
                      },
                    ),

                    const SizedBox(height: 24),

                    const JourneyTrustBanner(),

                    const SizedBox(height: 16),

                    JourneyBottomAction(
                      onPressed: _isLoading ||
                              (_isChanging &&
                                  _selectedStage == widget.currentStage)
                          ? null
                          : _continue,
                      isLoading: _isLoading,
                      label: !_isChanging
                          ? 'Tiếp tục'
                          : _selectedStage == widget.currentStage
                              ? 'Đang theo dõi lộ trình này'
                              : 'Đổi sang lộ trình này',
                      showHint: !_isChanging,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
