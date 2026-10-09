
import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PostpartumInfoCard extends StatefulWidget {
  const PostpartumInfoCard({super.key});

  @override
  State<PostpartumInfoCard> createState() =>
      _PostpartumInfoCardState();
}

class _PostpartumInfoCardState extends State<PostpartumInfoCard> {
  String _deliveryMethod = 'Sinh thường';
  bool _isBreastfeeding = true;
  DateTime _birthDate = DateTime(2026, 10, 8);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int get _daysSinceBirth {
    final today = DateUtils.dateOnly(DateTime.now());
    final birthDate = DateUtils.dateOnly(_birthDate);
    return today.difference(birthDate).inDays.clamp(0, 99999);
  }

  Future<void> _changeBirthDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() => _birthDate = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(
            icon: Icons.spa_rounded,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primaryLight,
            title: 'Thông tin phục hồi của Mẹ',
            subtitle: 'Chăm sóc thể trạng & dinh dưỡng hậu sản',
          ),
          const SizedBox(height: 22),

          const _FieldLabel('Ngày sinh của bé'),
          const SizedBox(height: 8),

          InkWell(
            onTap: _changeBirthDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _iconCircle(
                    Icons.calendar_month_rounded,
                    AppColors.primaryLight,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_birthDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bé ${_daysSinceBirth == 0 ? 'mới sinh' : 'tròn $_daysSinceBirth ngày tuổi'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_calendar_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dùng để tính số ngày hậu sản và các cột mốc thăm khám sức khỏe của mẹ.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),
          const _FieldLabel('Phương pháp sinh nở'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _deliveryOption(
                  label: 'Sinh thường',
                  icon: Icons.check_circle_rounded,
                ),
                _deliveryOption(
                  label: 'Sinh mổ',
                  icon: Icons.healing_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MomOi AI sẽ cá nhân hóa bài tập sàn chậu Kegel '
                    'và thực đơn phù hợp với quá trình phục hồi.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _iconCircle(
                  Icons.water_drop_rounded,
                  AppColors.mintLight,
                  AppColors.secondary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đang cho con bú / vắt sữa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cá nhân hóa gợi ý bữa ăn và vi chất lợi sữa.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isBreastfeeding,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _isBreastfeeding = value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryOption({
    required String label,
    required IconData icon,
  }) {
    final selected = _deliveryMethod == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _deliveryMethod = label);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;

  const _CardHeading({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

Widget _iconCircle(
  IconData icon,
  Color background,
  Color foreground,
) {
  return Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: background,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 20, color: foreground),
  );
}