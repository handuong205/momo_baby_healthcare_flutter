import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class NewbornProfileCard extends StatefulWidget {
  const NewbornProfileCard({super.key});

  @override
  State<NewbornProfileCard> createState() => _NewbornProfileCardState();
}

class _NewbornProfileCardState extends State<NewbornProfileCard> {
  final _nameController = TextEditingController(text: 'Bé Bắp');
  final _weightController = TextEditingController(text: '3.4');
  final _heightController = TextEditingController(text: '50.0');
  bool _isMultiSelect = true;
  String _gender = 'Bé gái';

  final List<String> _allergies = ['Đạm sữa bò', 'Hải sản', 'Lòng trắng trứng'];

  final Set<String> _selectedAllergies = {};

  bool get _noAllergies => _selectedAllergies.isEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _addAllergy() async {
    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm dị ứng'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập thực phẩm cần lưu ý',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext, text);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (value != null && value.trim().isNotEmpty) {
      setState(() {
        if (!_allergies.contains(value.trim())) {
          _allergies.add(value.trim());
        }
        _selectedAllergies.add(value.trim());
      });
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
          const Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.yellowLight,
                child: Icon(
                  Icons.child_care_rounded,
                  color: AppColors.warningYellow,
                  size: 25,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hồ sơ của Thiên Thần Nhỏ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Theo dõi chuẩn tăng trưởng WHO',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          _label('Tên gọi thân mật của bé'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration(
              hint: 'Ví dụ: Bé Bắp, Minh Khôi',
              icon: Icons.face_rounded,
            ),
          ),

          const SizedBox(height: 20),
          _label('Giới tính của bé'),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderOption('Bé trai', '👦'),
              const SizedBox(width: 10),
              _genderOption('Bé gái', '👧'),
            ],
          ),

          const SizedBox(height: 20),
          _label('Chỉ số phát triển hiện tại'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _metricField(
                  title: 'Cân nặng',
                  controller: _weightController,
                  unit: 'kg',
                  icon: Icons.monitor_weight_outlined,
                  badge: '✓ Chuẩn WHO',
                  badgeColor: AppColors.mintLight,
                  badgeTextColor: AppColors.secondary,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricField(
                  title: 'Chiều dài',
                  controller: _heightController,
                  unit: 'cm',
                  icon: Icons.straighten_rounded,
                  badge: '☆ Chuẩn sơ sinh',
                  badgeColor: AppColors.background,
                  badgeTextColor: AppColors.textSecondary,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _label('Dị ứng thực phẩm ghi nhận')),
              const Text(
                'Chọn nhiều mục',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Checkbox(
                value: _isMultiSelect,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isMultiSelect = value ?? false;

                    if (!_isMultiSelect && _selectedAllergies.length > 1) {
                      final firstSelected = _selectedAllergies.first;
                      _selectedAllergies
                        ..clear()
                        ..add(firstSelected);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              _allergyChip(
                'Không có dị ứng',
                selected: _noAllergies,
                onTap: () {
                  setState(() => _selectedAllergies.clear());
                },
              ),
              ..._allergies.map(
                (allergy) => _allergyChip(
                  allergy,
                  selected: _selectedAllergies.contains(allergy),
                  onTap: () {
                    setState(() {
                      if (_selectedAllergies.contains(allergy)) {
                        _selectedAllergies.remove(allergy);
                      } else {
                        if (!_isMultiSelect) {
                          _selectedAllergies.clear();
                        }
                        _selectedAllergies.add(allergy);
                      }
                    });
                  },
                ),
              ),
              InkWell(
                onTap: _addAllergy,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 15, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Thêm khác',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String gender, String emoji) {
    final selected = _gender == gender;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gender = gender),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricField({
    required String title,
    required TextEditingController controller,
    required String unit,
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required TextInputType keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(icon, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allergyChip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
