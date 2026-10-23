import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

/// Thanh chọn cảm xúc kiểu Messenger.
///
/// - Nhấn giữ [child]: thanh bật lên phía trên (thiếu chỗ thì phía dưới).
/// - Không nhấc tay, kéo ngón qua các lựa chọn: lựa chọn dưới ngón tay
///   phóng to và hiện tên; thả tay để chọn.
/// - Thả tay ngoài thanh: thanh vẫn mở để chạm chọn; chạm ra ngoài để đóng.
/// - Chạm thường vào [child]: gọi [onTap], hoặc mở thanh nếu [onTap] null.
class ReactionPicker<T> extends StatefulWidget {
  final List<T> options;
  final T? selected;
  final Widget Function(T option, double size) itemBuilder;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;
  final VoidCallback? onTap;
  final double itemSize;
  final Widget child;

  const ReactionPicker({
    super.key,
    required this.options,
    required this.itemBuilder,
    required this.labelOf,
    required this.onSelected,
    required this.child,
    this.selected,
    this.onTap,
    this.itemSize = 40,
  });

  @override
  State<ReactionPicker<T>> createState() => _ReactionPickerState<T>();
}

class _ReactionPickerState<T> extends State<ReactionPicker<T>> {
  /// Lề trong của thanh, đã gồm viền 1px (xem `_ReactionBar._buildBar`).
  static const double _padding = 8;

  final GlobalKey<_ReactionBarState<T>> _barKey = GlobalKey();
  OverlayEntry? _entry;
  RenderBox? _overlayBox;
  Rect? _barRect;
  int? _hovered;

  double get _slot => widget.itemSize + 10;

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _open() {
    if (_entry != null) return;
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || overlayBox == null) return;

    final childRect =
        box.localToGlobal(Offset.zero, ancestor: overlayBox) & box.size;
    final screen = overlayBox.size;
    final safeTop = MediaQuery.paddingOf(context).top;

    final width = widget.options.length * _slot + _padding * 2;
    final height = widget.itemSize + _padding * 2;
    final left = (childRect.center.dx - width / 2).clamp(
      12.0,
      (screen.width - 12 - width).clamp(12.0, double.infinity),
    );
    // Chừa ~44px phía trên cho nhãn tên khi phóng to.
    var top = childRect.top - height - 12;
    if (top < safeTop + 44) top = childRect.bottom + 12;

    _overlayBox = overlayBox;
    _barRect = Rect.fromLTWH(left, top, width, height);
    _hovered = null;
    _entry = OverlayEntry(
      builder: (_) => _ReactionBar<T>(
        key: _barKey,
        rect: _barRect!,
        padding: _padding,
        slot: _slot,
        itemSize: widget.itemSize,
        options: widget.options,
        selected: widget.selected,
        itemBuilder: widget.itemBuilder,
        labelOf: widget.labelOf,
        onSelectIndex: _select,
        onDismiss: _close,
      ),
    );
    overlay.insert(_entry!);
    HapticFeedback.mediumImpact();
  }

  void _close() {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    final bar = _barKey.currentState;
    if (bar == null) {
      entry.remove();
    } else {
      bar.dismiss().whenComplete(entry.remove);
    }
  }

  void _select(int index) {
    _close();
    widget.onSelected(widget.options[index]);
  }

  int? _indexAt(Offset global) {
    final rect = _barRect;
    final overlayBox = _overlayBox;
    if (rect == null || overlayBox == null) return null;
    final p = overlayBox.globalToLocal(global);
    // Cho phép lệch dọc một chút để kéo ngón tay thoải mái.
    if (p.dy < rect.top - 70 || p.dy > rect.bottom + 50) return null;
    final i = ((p.dx - rect.left - _padding) / _slot).floor();
    return i >= 0 && i < widget.options.length ? i : null;
  }

  void _hover(Offset global) {
    final i = _indexAt(global);
    if (i == _hovered) return;
    _hovered = i;
    if (i != null) HapticFeedback.selectionClick();
    _barKey.currentState?.setHovered(i);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap ?? _open,
      onLongPressStart: (d) {
        _open();
        _hover(d.globalPosition);
      },
      onLongPressMoveUpdate: (d) => _hover(d.globalPosition),
      onLongPressEnd: (_) {
        final i = _hovered;
        if (i != null) _select(i);
      },
      child: widget.child,
    );
  }
}

class _ReactionBar<T> extends StatefulWidget {
  final Rect rect;
  final double padding;
  final double slot;
  final double itemSize;
  final List<T> options;
  final T? selected;
  final Widget Function(T option, double size) itemBuilder;
  final String Function(T option) labelOf;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onDismiss;

  const _ReactionBar({
    super.key,
    required this.rect,
    required this.padding,
    required this.slot,
    required this.itemSize,
    required this.options,
    required this.selected,
    required this.itemBuilder,
    required this.labelOf,
    required this.onSelectIndex,
    required this.onDismiss,
  });

  @override
  State<_ReactionBar<T>> createState() => _ReactionBarState<T>();
}

class _ReactionBarState<T> extends State<_ReactionBar<T>>
    with SingleTickerProviderStateMixin {
  static const double _hoverScale = 1.6;
  static const double _borderWidth = 1;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 160),
  )..forward();

  int? _hovered;

  void setHovered(int? index) {
    if (mounted && index != _hovered) setState(() => _hovered = index);
  }

  Future<void> dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.rect;
    final barIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeIn,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Chạm / vuốt ra ngoài để đóng.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onDismiss,
              onPanStart: (_) => widget.onDismiss(),
            ),
          ),
          Positioned.fromRect(
            rect: rect,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0, 0.3),
              ),
              child: ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(barIn),
                alignment: Alignment.bottomCenter,
                child: _buildBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar() {
    return Container(
      // Viền chiếm chỗ bên trong Container, nên trừ ra để hàng emoji
      // vừa khít chiều rộng đã tính (tránh tràn 2px).
      padding: EdgeInsets.all(widget.padding - _borderWidth),
      decoration: BoxDecoration(
        color: MomTheme.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MomTheme.border, width: _borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x262C2118),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < widget.options.length; i++) _buildItem(i),
        ],
      ),
    );
  }

  Widget _buildItem(int i) {
    final option = widget.options[i];
    final size = widget.itemSize;
    final isHovered = _hovered == i;
    final scale = isHovered
        ? _hoverScale
        : _hovered != null
        ? 0.88
        : 1.0;

    // Các emoji nảy lên lần lượt khi thanh mở.
    final start = (0.12 + i * 0.07).clamp(0.0, 0.7);
    final popIn = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        (start + 0.45).clamp(0.0, 1.0),
        curve: Curves.elasticOut,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelectIndex(i),
      child: SizedBox(
        width: widget.slot,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedBuilder(
              animation: popIn,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, 14 * (1 - popIn.value)),
                child: Transform.scale(
                  scale: popIn.value.clamp(0.0, 1.3),
                  child: child,
                ),
              ),
              child: AnimatedScale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: SizedBox.square(
                  dimension: size,
                  child: widget.itemBuilder(option, size),
                ),
              ),
            ),
            // Tên lựa chọn khi đang trỏ vào.
            if (isHovered)
              Positioned(
                bottom: size * _hoverScale + 6,
                left: -40,
                right: -40,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: MomTheme.charcoal.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.labelOf(option),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MomTheme.white,
                      ),
                    ),
                  ),
                ),
              ),
            // Chấm nhỏ dưới lựa chọn hiện tại.
            if (_hovered == null && option == widget.selected)
              Positioned(
                bottom: -7,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: MomTheme.roseDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
