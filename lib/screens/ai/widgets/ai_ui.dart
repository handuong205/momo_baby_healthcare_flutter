import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:momo_baby_healthcare_flutter/config/advisor_config.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';

/// Các khối giao diện dùng chung cho 3 màn AI (10–12).
/// Chữ tối thiểu 14px, nút cao ≥ 48px để mẹ dễ đọc, dễ bấm.

const String _font = 'PlusJakartaSans';

class AiText {
  AiText._();

  static const TextStyle title = TextStyle(
    fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w800, color: MomTheme.charcoal, height: 1.25);
  static const TextStyle section = TextStyle(
    fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700, color: MomTheme.charcoal, height: 1.3);
  static const TextStyle body = TextStyle(
    fontFamily: _font, fontSize: 16, color: MomTheme.charcoalMid, height: 1.5);
  static const TextStyle muted = TextStyle(
    fontFamily: _font, fontSize: 14, color: MomTheme.muted, height: 1.45);
  static const TextStyle label = TextStyle(
    fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w700, color: MomTheme.charcoal);
}

/// Mở số điện thoại / Zalo / link; báo lỗi nhẹ nếu máy không mở được.
Future<void> launchExternal(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không mở được ứng dụng trên máy này.')),
    );
  }
}

Uri telUri(String phone) => Uri(scheme: 'tel', path: phone);

/// Thẻ trắng bo góc dùng làm nền cho mỗi khối nội dung.
class AiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  const AiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = MomTheme.white,
    this.borderColor = MomTheme.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}

/// Tiêu đề khối có icon tròn.
class AiSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color background;

  const AiSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.color = MomTheme.roseDark,
    this.background = MomTheme.pinkLight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AiText.section)),
      ],
    );
  }
}

/// Danh sách gạch đầu dòng.
class AiBulletList extends StatelessWidget {
  final List<String> items;
  final Color dotColor;

  const AiBulletList({super.key, required this.items, this.dotColor = MomTheme.sage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 9, right: 10),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                Expanded(child: Text(item, style: AiText.body)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Nút to, bo tròn, có icon.
class AiPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool outlined;

  const AiPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.background = MomTheme.roseDark,
    this.foreground = MomTheme.white,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 50)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: outlined ? BorderSide(color: foreground.withValues(alpha: 0.4)) : BorderSide.none,
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(outlined ? Colors.transparent : background),
      foregroundColor: WidgetStatePropertyAll(outlined ? foreground : foreground),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      elevation: const WidgetStatePropertyAll(0),
    );
    return TextButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

/// Thẻ bác sĩ cố vấn: [compact] cho đầu màn Kiểm tra triệu chứng,
/// bản đầy đủ cho cuối màn Kết quả (có chép số điện thoại).
class DoctorCard extends StatelessWidget {
  final bool compact;
  final bool urgent;

  const DoctorCard({super.key, this.compact = false, this.urgent = false});

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: compact ? 52 : 64,
      height: compact ? 52 : 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MomTheme.sageLight,
        shape: BoxShape.circle,
        border: Border.all(color: MomTheme.white, width: 3),
      ),
      child: Icon(Icons.medical_services_rounded, color: MomTheme.sageDark, size: compact ? 26 : 32),
    );

    final buttons = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        AiPillButton(
          icon: Icons.call_rounded,
          label: 'Gọi bác sĩ',
          background: MomTheme.sageDark,
          onPressed: () => launchExternal(context, telUri(AdvisorConfig.doctorPhone)),
        ),
        AiPillButton(
          icon: Icons.chat_bubble_rounded,
          label: 'Nhắn Zalo',
          background: AppColors.blue,
          onPressed: () => launchExternal(
            context,
            Uri.parse('https://zalo.me/${AdvisorConfig.doctorPhone}'),
          ),
        ),
        if (!compact)
          AiPillButton(
            icon: Icons.copy_rounded,
            label: 'Chép số',
            outlined: true,
            foreground: MomTheme.charcoalMid,
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: AdvisorConfig.doctorPhone));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chép số ${AdvisorConfig.doctorPhoneDisplay}')),
                );
              }
            },
          ),
      ],
    );

    return AiCard(
      color: urgent ? AppColors.roseLight : MomTheme.sageLight.withValues(alpha: 0.55),
      borderColor: urgent ? AppColors.rose.withValues(alpha: 0.35) : MomTheme.sageMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              avatar,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AdvisorConfig.doctorRole,
                      style: AiText.muted.copyWith(
                        color: MomTheme.sageDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AdvisorConfig.doctorName,
                      style: AiText.title.copyWith(fontSize: compact ? 20 : 22),
                    ),
                    if (!compact)
                      Text('Điện thoại / Zalo: ${AdvisorConfig.doctorPhoneDisplay}', style: AiText.body),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            compact
                ? 'Cần hỏi thêm, mẹ có thể gọi hoặc nhắn Zalo cho bác sĩ.'
                : 'Mẹ nên hỏi ý kiến bác sĩ trước khi tự dùng thuốc hoặc khi triệu chứng kéo dài.',
            style: AiText.muted,
          ),
          const SizedBox(height: 14),
          buttons,
        ],
      ),
    );
  }
}

/// Miễn trừ trách nhiệm y tế + nút gọi cấp cứu 115.
class MedicalDisclaimer extends StatelessWidget {
  final String? extra;

  const MedicalDisclaimer({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      color: AppColors.amberLight,
      borderColor: AppColors.amber.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: MomTheme.amberDark, size: 24),
              SizedBox(width: 10),
              Text('Miễn trừ trách nhiệm', style: AiText.label),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kết quả do AI gợi ý chỉ để mẹ tham khảo, không phải chẩn đoán của bác sĩ. '
            'Mom Ơi! không thay thế việc thăm khám và điều trị. '
            '${extra ?? ''}',
            style: AiText.body.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 12),
          AiPillButton(
            icon: Icons.emergency_rounded,
            label: 'Cấp cứu: gọi ${AdvisorConfig.emergencyNumber}',
            background: AppColors.rose,
            onPressed: () => launchExternal(context, telUri(AdvisorConfig.emergencyNumber)),
          ),
        ],
      ),
    );
  }
}

/// Khung báo lỗi có nút thử lại.
class AiErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AiErrorBox({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      color: AppColors.roseLight,
      borderColor: AppColors.rose.withValues(alpha: 0.3),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.rose),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AiText.body.copyWith(fontSize: 15))),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

/// Câu báo lỗi cho mẹ: lỗi từ server (ApiException) hoặc lỗi do repository ném ra.
String aiErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  return text.isEmpty ? 'Đã xảy ra lỗi. Mẹ thử lại nhé.' : text;
}

String formatViDateTime(DateTime? d) {
  if (d == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)} · ${two(d.day)}/${two(d.month)}/${d.year}';
}
