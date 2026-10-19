import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bảng màu MOM_THEME / RADII của app Mobile (src/theme/colors.ts).
class MomTheme {
  const MomTheme._();

  static const cream = Color(0xFFFAF6F0);
  static const creamSoft = Color(0xFFFCF9F5);
  static const rose = Color(0xFFE8B4C4);
  static const roseDark = Color(0xFFC97A95);
  static const roseDeep = Color(0xFFB85B7A);
  static const pink = Color(0xFFF2D0DC);
  static const pinkLight = Color(0xFFFFF0F5);
  static const sage = Color(0xFF8AA898);
  static const sageDark = Color(0xFF5F7A6B);
  static const sageLight = Color(0xFFE8F2EC);
  static const amberLight = Color(0xFFFFF4EB);
  static const amberDark = Color(0xFFC97842);
  static const lavender = Color(0xFFA799B7);
  static const lavenderLight = Color(0xFFF3EEF8);
  static const beige = Color(0xFFE8DDD0);
  static const beigeLight = Color(0xFFF2EBE1);
  static const charcoal = Color(0xFF2C2118);
  static const charcoalMid = Color(0xFF4A3F35);
  static const muted = Color(0xFF7A6E65);
  static const mutedLight = Color(0xFFA69B92);
  static const white = Colors.white;
  static const border = Color(0xFFEFE7DC);
  static const borderSoft = Color(0xFFF3EDE4);
  static const danger = Color(0xFFD95368);
  static const dangerLight = Color(0xFFFDECEF);
  static const dangerBorder = Color(0xFFFECACA);
  static const emergency = Color(0xFFD92D20);
  static const purple = Color(0xFF8E6BB8);
  static const blue = Color(0xFF4A88C7);

  static const radiusControl = 14.0;
  static const radiusCard = 20.0;
  static const radiusHero = 28.0;

  static const cardShadow = [
    BoxShadow(color: Color(0x0D2C2118), offset: Offset(0, 6), blurRadius: 14),
  ];
  static const smallShadow = [
    BoxShadow(color: Color(0x0A2C2118), offset: Offset(0, 2), blurRadius: 4),
  ];
}

/// Khung màn hình con giống `Screen` của Mobile: nút quay lại tròn,
/// eyebrow + tiêu đề, phụ đề và kéo để tải lại.
class MomScreen extends StatelessWidget {
  const MomScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.right,
    this.onRefresh,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? right;
  final Future<void> Function()? onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 48),
      children: [
        Row(
          children: [
            if (Navigator.of(context).canPop()) ...[
              Material(
                color: MomTheme.white,
                shape: const CircleBorder(
                  side: BorderSide(color: MomTheme.border),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      LucideIcons.arrowLeft,
                      size: 20,
                      color: MomTheme.charcoal,
                      semanticLabel: 'Quay lại',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null)
                    Text(
                      eyebrow!.toUpperCase(),
                      style: const TextStyle(
                        color: MomTheme.roseDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: MomTheme.charcoal,
                      fontSize: 24,
                      height: 30 / 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ?right,
          ],
        ),
        const SizedBox(height: 6),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(subtitle!, style: MomText.muted),
          ),
        ...children,
      ],
    );
    return Scaffold(
      backgroundColor: MomTheme.cream,
      body: onRefresh == null
          ? list
          : RefreshIndicator(
              color: MomTheme.roseDark,
              onRefresh: onRefresh!,
              child: list,
            ),
    );
  }
}

class MomText {
  const MomText._();

  static const muted = TextStyle(
    color: MomTheme.muted,
    fontSize: 13,
    height: 19 / 13,
  );
  static const body = TextStyle(
    color: MomTheme.charcoalMid,
    fontSize: 14,
    height: 21 / 14,
  );
  static const label = TextStyle(
    color: MomTheme.charcoal,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
}

class MomCard extends StatelessWidget {
  const MomCard({
    super.key,
    required this.child,
    this.color = MomTheme.white,
    this.borderColor = MomTheme.borderSoft,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 14),
    this.shadow = MomTheme.cardShadow,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(MomTheme.radiusCard),
      border: Border.all(color: borderColor),
      boxShadow: shadow,
    ),
    child: child,
  );
}

class MomSectionTitle extends StatelessWidget {
  const MomSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.right,
  });

  final String title;
  final String? subtitle;
  final Widget? right;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: MomTheme.charcoal,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(color: MomTheme.muted, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        ?right,
      ],
    ),
  );
}

class MomPrimaryButton extends StatelessWidget {
  const MomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.color = MomTheme.roseDark,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final inactive = onPressed == null || loading;
    return Opacity(
      opacity: inactive ? 0.55 : 1,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(MomTheme.radiusControl),
        child: InkWell(
          borderRadius: BorderRadius.circular(MomTheme.radiusControl),
          onTap: inactive ? null : onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MomTheme.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 17, color: MomTheme.white),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: MomTheme.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class MomSecondaryButton extends StatelessWidget {
  const MomSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? 0.55 : 1,
    child: Material(
      color: MomTheme.pinkLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MomTheme.radiusControl),
        side: const BorderSide(color: MomTheme.pink),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(MomTheme.radiusControl),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: MomTheme.roseDeep),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: MomTheme.roseDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MomField extends StatelessWidget {
  const MomField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.multiline = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(MomTheme.radiusControl),
      borderSide: BorderSide(color: color),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: MomText.label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: multiline ? 3 : 1,
            maxLines: multiline ? 5 : 1,
            style: const TextStyle(color: MomTheme.charcoal, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: MomTheme.mutedLight),
              filled: true,
              fillColor: MomTheme.creamSoft,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: border(MomTheme.border),
              enabledBorder: border(MomTheme.border),
              focusedBorder: border(MomTheme.roseDark),
            ),
          ),
        ],
      ),
    );
  }
}

class MomChip extends StatelessWidget {
  const MomChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? MomTheme.roseDark : MomTheme.white,
    shape: StadiumBorder(
      side: BorderSide(color: selected ? MomTheme.roseDark : MomTheme.border),
    ),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected
                    ? MomTheme.white
                    : iconColor ?? MomTheme.charcoalMid,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? MomTheme.white : MomTheme.charcoalMid,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Dòng cảnh báo đỏ của panel Khẩn cấp (Mobile `Warning`).
class MomWarning extends StatelessWidget {
  const MomWarning(this.text, {super.key, this.icon = LucideIcons.lifeBuoy});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: MomTheme.dangerLight,
      borderRadius: BorderRadius.circular(MomTheme.radiusControl),
      border: Border.all(color: MomTheme.dangerBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: MomTheme.danger),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: MomTheme.danger,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class MomLoadingView extends StatelessWidget {
  const MomLoadingView({super.key, this.text = 'Đang tải dữ liệu...'});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        const CircularProgressIndicator(color: MomTheme.roseDark),
        const SizedBox(height: 8),
        Text(text, style: MomText.muted),
      ],
    ),
  );
}

class MomStateCard extends StatelessWidget {
  const MomStateCard({
    super.key,
    required this.emoji,
    required this.title,
    this.body,
    this.action,
  });

  /// Thẻ "Chưa tải được dữ liệu" giống `ErrorState` của Mobile.
  factory MomStateCard.error(String message, {VoidCallback? onRetry}) =>
      MomStateCard(
        emoji: '⚠️',
        title: 'Chưa tải được dữ liệu',
        body: message,
        action: onRetry == null
            ? null
            : MomSecondaryButton(
                label: 'Thử lại',
                icon: LucideIcons.refreshCw,
                onPressed: onRetry,
              ),
      );

  final String emoji;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
    decoration: BoxDecoration(
      color: MomTheme.white,
      borderRadius: BorderRadius.circular(MomTheme.radiusCard),
      border: Border.all(color: MomTheme.border),
    ),
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MomTheme.charcoal,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 6),
          Text(body!, textAlign: TextAlign.center, style: MomText.muted),
        ],
        if (action != null) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: action),
        ],
      ],
    ),
  );
}

/// Hiện thông báo dạng Alert.alert của Mobile.
Future<void> showMomAlert(BuildContext context, String title, String body) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
