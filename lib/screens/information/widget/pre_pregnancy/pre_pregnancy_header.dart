import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PrePregnancyHeader extends StatelessWidget {
  const PrePregnancyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                // Back
                Material(
                  color: AppColors.surface.withValues(alpha: 0.7),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                const Spacer(),


                const SizedBox(width: 12),

              ],
            ),
          ),
        ),
      ),
    );
  }
}