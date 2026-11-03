import 'package:flutter/material.dart';

import 'pregnancy_week_picker.dart';
import 'pregnancy_edd.dart';
import 'baby_nickname_input.dart';

class PregnancyDetails extends StatelessWidget {
  final int currentWeek;
  final DateTime dueDate;

  final TextEditingController nicknameController;

  final ValueChanged<int> onWeekChanged;
  final VoidCallback onSelectDueDate;

  const PregnancyDetails({
    super.key,
    required this.currentWeek,
    required this.dueDate,
    required this.nicknameController,
    required this.onWeekChanged,
    required this.onSelectDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),
      child: Column(
        children: [
          // Section divider
          Row(
            children: [
              const Expanded(
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Text(
                  '♡  Thông tin thai kỳ của Mẹ',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Expanded(
                child: Divider(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          PregnancyWeekPicker(
            currentWeek: currentWeek,
            onWeekChanged: onWeekChanged,
          ),

          const SizedBox(height: 16),

          PregnancyEdd(
            dueDate: dueDate,
            onTap: onSelectDueDate,
          ),

          const SizedBox(height: 16),

          BabyNicknameInput(
            controller: nicknameController,
          ),
        ],
      ),
    );
  }
}