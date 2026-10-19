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

enum PregnancyStage { prePregnancy, pregnancy, postpartum }

class JourneySelectionScreen extends StatefulWidget {
  const JourneySelectionScreen({super.key});

  @override
  State<JourneySelectionScreen> createState() => _JourneySelectionScreenState();
}

class _JourneySelectionScreenState extends State<JourneySelectionScreen> {
  PregnancyStage _selectedStage = PregnancyStage.prePregnancy;

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

  Future<void> _continue() async {
  if (_isLoading) return;

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
                    const SizedBox(height: 8),

                    const JourneyHeader(),

                    const SizedBox(height: 20),

                    // =========================
                    // PRE-PREGNANCY
                    // =========================
                    JourneyCard(
                      stage: PregnancyStage.prePregnancy,
                      selectedStage: _selectedStage,
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
                      onPressed: _isLoading ? null : _continue,
                      isLoading: _isLoading,
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
