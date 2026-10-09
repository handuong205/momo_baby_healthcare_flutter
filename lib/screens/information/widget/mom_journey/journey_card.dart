import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/journey_selection_screen.dart';

import 'pregnancy_details.dart';


class JourneyCard extends StatelessWidget {
  final PregnancyStage stage;
  final PregnancyStage selectedStage;

  final String emoji;
  final String title;
  final String description;

  final bool popular;

  final int? currentWeek;
  final DateTime? dueDate;
  final TextEditingController? nicknameController;

  final ValueChanged<int>? onWeekChanged;
  final VoidCallback? onSelectDueDate;

  final VoidCallback onTap;

  const JourneyCard({
    super.key,
    required this.stage,
    required this.selectedStage,
    required this.emoji,
    required this.title,
    required this.description,
    required this.onTap,
    this.popular = false,
    this.currentWeek,
    this.dueDate,
    this.nicknameController,
    this.onWeekChanged,
    this.onSelectDueDate,
  });

  bool get isSelected => stage == selectedStage;

  @override
  Widget build(BuildContext context) {
    final titleColor = isSelected
        ? AppColors.primary
        : AppColors.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surface
              : AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isSelected ? 0.06 : 0.03,
              ),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Emoji
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Title + description
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 28,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (popular)
                              Container(
                                margin: const EdgeInsets.only(
                                  bottom: 4,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(
                                    999,
                                  ),
                                ),
                                child: const Text(
                                  'Phổ biến nhất ✨',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (isSelected &&
                    stage == PregnancyStage.pregnancy &&
                    currentWeek != null &&
                    dueDate != null &&
                    nicknameController != null)
                  PregnancyDetails(
                    currentWeek: currentWeek!,
                    dueDate: dueDate!,
                    nicknameController:
                        nicknameController!,
                    onWeekChanged: onWeekChanged!,
                    onSelectDueDate:
                        onSelectDueDate!,
                  ),
              ],
            ),

            // Radio
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surface
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}