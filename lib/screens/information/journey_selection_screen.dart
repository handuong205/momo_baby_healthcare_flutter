import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
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

  void _continue() {
    switch (_selectedStage) {
      case PregnancyStage.prePregnancy:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrePregnancyScreen()),
        );
        break;

      case PregnancyStage.pregnancy:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PregnancyScreen()),
        );
        break;

      case PregnancyStage.postpartum:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostpartumSetupScreen()),
        );
        break;
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
                      title: 'Đang mang thai (Bé trong bụng)',
                      description: 'Đồng hành theo dõi tuần thai, dinh dưỡng mẹ bầu và chuẩn bị sinh trọn gói.',
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
                      nicknameController: _nicknameController,
                      onTap: () {
                        _selectStage(PregnancyStage.postpartum);
                      },
                    ),

                    const SizedBox(height: 24),

                    const JourneyTrustBanner(),

                    const SizedBox(height: 16),

                    JourneyBottomAction(onPressed: _continue),

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
