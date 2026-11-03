import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

/// Hiệu ứng rơi / pháo giấy phủ lên toàn màn hình (không chặn thao tác).
///
/// - [Celebration.rain]: icon / ảnh rơi từ trên xuống (vd. emoji tâm trạng).
/// - [Celebration.confetti]: pháo giấy bắn từ hai góc dưới, kèm lời chúc.
///
/// Khi máy bật "giảm chuyển động" thì bỏ qua hiệu ứng.
class Celebration {
  Celebration._();

  static final math.Random _random = math.Random();

  /// [itemBuilder] vẽ một hạt với kích thước cho trước.
  static void rain(
    BuildContext context, {
    required Widget Function(double size) itemBuilder,
    int count = 32,
    double minSize = 26,
    double maxSize = 44,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    if (_reduceMotion(context)) return;
    final particles = List.generate(
      count,
      (_) => _RainParticle.random(_random, minSize, maxSize),
    );
    _insert(
      context,
      (onDone) => _RainLayer(
        particles: particles,
        itemBuilder: itemBuilder,
        duration: duration,
        onDone: onDone,
      ),
    );
  }

  static void confetti(
    BuildContext context, {
    String emoji = '🎉',
    String? title,
    String? message,
    int count = 280,
    Duration duration = const Duration(milliseconds: 3800),
  }) {
    if (_reduceMotion(context)) return;
    final particles = List.generate(
      count,
      (i) => _ConfettiParticle.random(_random, fromLeft: i.isEven),
    );
    _insert(
      context,
      (onDone) => _ConfettiLayer(
        particles: particles,
        duration: duration,
        emoji: emoji,
        title: title,
        message: message,
        onDone: onDone,
      ),
    );
  }

  static bool _reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static void _insert(
    BuildContext context,
    Widget Function(VoidCallback onDone) builder,
  ) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => IgnorePointer(child: builder(() => entry.remove())),
    );
    overlay.insert(entry);
  }
}

// ─────────────────────────── Rain ───────────────────────────

class _RainParticle {
  final double x; // 0..1 theo chiều ngang
  final double delay; // 0..0.35 thời lượng
  final double span; // phần thời lượng để rơi hết màn hình
  final double size;
  final double rotation; // radian ban đầu
  final double spin; // radian xoay thêm khi rơi
  final double swayAmp;
  final double swayFreq;
  final double swayPhase;

  const _RainParticle({
    required this.x,
    required this.delay,
    required this.span,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.swayAmp,
    required this.swayFreq,
    required this.swayPhase,
  });

  factory _RainParticle.random(math.Random r, double minSize, double maxSize) {
    final delay = r.nextDouble() * 0.35;
    return _RainParticle(
      x: 0.05 + r.nextDouble() * 0.9,
      delay: delay,
      span: (1 - delay) * (0.75 + r.nextDouble() * 0.25),
      size: minSize + r.nextDouble() * (maxSize - minSize),
      rotation: (r.nextDouble() - 0.5) * 0.6,
      spin: (r.nextDouble() - 0.5) * 1.6,
      swayAmp: 8 + r.nextDouble() * 18,
      swayFreq: 1 + r.nextDouble() * 1.5,
      swayPhase: r.nextDouble() * math.pi * 2,
    );
  }
}

class _RainLayer extends StatefulWidget {
  final List<_RainParticle> particles;
  final Widget Function(double size) itemBuilder;
  final Duration duration;
  final VoidCallback onDone;

  const _RainLayer({
    required this.particles,
    required this.itemBuilder,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_RainLayer> createState() => _RainLayerState();
}

class _RainLayerState extends State<_RainLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward().whenComplete(widget.onDone);

  // Mỗi hạt chỉ dựng widget một lần, khung hình sau chỉ đổi vị trí.
  late final List<Widget> _children = [
    for (final p in widget.particles)
      SizedBox.square(dimension: p.size, child: widget.itemBuilder(p.size)),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final v = _controller.value;
            return Stack(
              children: [
                for (var i = 0; i < widget.particles.length; i++)
                  _buildParticle(widget.particles[i], _children[i], v, w, h),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildParticle(
    _RainParticle p,
    Widget child,
    double v,
    double w,
    double h,
  ) {
    final t = ((v - p.delay) / p.span).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return const SizedBox.shrink();

    // Rơi nhanh dần nhẹ như có trọng lực.
    final fall = Curves.easeInSine.transform(t);
    final top = -p.size + fall * (h + p.size * 2);
    final sway =
        math.sin(t * math.pi * 2 * p.swayFreq + p.swayPhase) * p.swayAmp;
    final opacity = t < 0.08
        ? t / 0.08
        : t > 0.85
        ? (1 - t) / 0.15
        : 1.0;

    return Positioned(
      left: p.x * w - p.size / 2 + sway,
      top: top,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(angle: p.rotation + p.spin * t, child: child),
      ),
    );
  }
}

// ─────────────────────────── Confetti ───────────────────────────

const List<Color> _confettiColors = [
  MomTheme.roseDark,
  MomTheme.rose,
  MomTheme.pink,
  MomTheme.sage,
  MomTheme.amber,
  MomTheme.lavender,
  MomTheme.blue,
  Color(0xFFFFD166),
];

enum _ConfettiShape { rect, circle, strip }

class _ConfettiParticle {
  final bool fromLeft;
  final double delay; // giây
  final double angle; // hướng bắn (radian, so với phương thẳng đứng)
  final double power; // 0..1, bắn cao bao nhiêu phần màn hình
  final double fallSpeed; // phần màn hình / giây khi rơi
  final double swayAmp;
  final double swayFreq;
  final double swayPhase;
  final double spin; // vòng / giây
  final double flip; // vòng lật / giây (hiệu ứng 3D)
  final double width;
  final double height;
  final Color color;
  final _ConfettiShape shape;

  const _ConfettiParticle({
    required this.fromLeft,
    required this.delay,
    required this.angle,
    required this.power,
    required this.fallSpeed,
    required this.swayAmp,
    required this.swayFreq,
    required this.swayPhase,
    required this.spin,
    required this.flip,
    required this.width,
    required this.height,
    required this.color,
    required this.shape,
  });

  factory _ConfettiParticle.random(math.Random r, {required bool fromLeft}) {
    final shape = _ConfettiShape.values[r.nextInt(3)];
    final size = 6 + r.nextDouble() * 6;
    return _ConfettiParticle(
      fromLeft: fromLeft,
      delay: r.nextDouble() * 0.25,
      angle: 0.15 + r.nextDouble() * 0.55,
      power: 0.55 + r.nextDouble() * 0.4,
      fallSpeed: 0.16 + r.nextDouble() * 0.12,
      swayAmp: 10 + r.nextDouble() * 22,
      swayFreq: 0.6 + r.nextDouble() * 1.0,
      swayPhase: r.nextDouble() * math.pi * 2,
      spin: (r.nextDouble() - 0.5) * 3,
      flip: 1 + r.nextDouble() * 2.5,
      width: shape == _ConfettiShape.strip ? size * 0.5 : size,
      height: shape == _ConfettiShape.strip ? size * 1.8 : size * 0.65,
      color: _confettiColors[r.nextInt(_confettiColors.length)],
      shape: shape,
    );
  }
}

class _ConfettiLayer extends StatefulWidget {
  final List<_ConfettiParticle> particles;
  final Duration duration;
  final String emoji;
  final String? title;
  final String? message;
  final VoidCallback onDone;

  const _ConfettiLayer({
    required this.particles,
    required this.duration,
    required this.emoji,
    required this.onDone,
    this.title,
    this.message,
  });

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = widget.duration.inMilliseconds / 1000;
    final hasCard = widget.title != null || widget.message != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _ConfettiPainter(
            particles: widget.particles,
            animation: _controller,
            totalSeconds: seconds,
          ),
        ),
        if (hasCard)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Hiện ra trong 12% đầu, mờ dần ở 15% cuối.
              final v = _controller.value;
              final appear = Curves.easeOutBack.transform(
                (v / 0.12).clamp(0.0, 1.0),
              );
              final fade = v > 0.85 ? (1 - v) / 0.15 : 1.0;
              return Opacity(
                opacity: (appear.clamp(0.0, 1.0) * fade).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + 0.15 * appear,
                  child: child,
                ),
              );
            },
            child: SafeArea(
              child: Align(
                alignment: const Alignment(0, -0.35),
                child: _CelebrationCard(
                  emoji: widget.emoji,
                  title: widget.title,
                  message: widget.message,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final Animation<double> animation;
  final double totalSeconds;

  _ConfettiPainter({
    required this.particles,
    required this.animation,
    required this.totalSeconds,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value * totalSeconds;
    final w = size.width;
    final h = size.height;
    // Gia tốc trọng trường theo chiều cao màn hình, để bắn lên đủ cao.
    final g = h * 2.2;
    final paint = Paint();

    for (final p in particles) {
      final t = time - p.delay;
      if (t <= 0) continue;

      // Bắn lên từ góc dưới: v0 đủ để đạt độ cao power * h.
      final v0 = math.sqrt(2 * g * p.power * h);
      final vx = math.sin(p.angle) * v0 * 0.55 * (p.fromLeft ? 1 : -1);
      final vy = -math.cos(p.angle) * v0;
      final tPeak = -vy / g;

      final x0 = p.fromLeft ? 0.0 : w;
      final y0 = h + 10;

      double x;
      double y;
      if (t < tPeak) {
        x = x0 + vx * t;
        y = y0 + vy * t + 0.5 * g * t * t;
      } else {
        // Sau đỉnh: rơi chậm, lắc lư như giấy.
        final xPeak = x0 + vx * tPeak;
        final yPeak = y0 + vy * tPeak + 0.5 * g * tPeak * tPeak;
        final tf = t - tPeak;
        x =
            xPeak +
            vx * 0.15 * tf +
            math.sin(tf * math.pi * 2 * p.swayFreq + p.swayPhase) * p.swayAmp;
        y = yPeak + p.fallSpeed * h * tf;
      }
      if (y > h + 20) continue;

      // Mờ dần trong 0,6 giây cuối.
      final remain = totalSeconds - time;
      final opacity = remain < 0.6 ? (remain / 0.6).clamp(0.0, 1.0) : 1.0;
      paint.color = p.color.withValues(alpha: opacity);

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * t * math.pi * 2)
        // Lật theo trục ngang để giấy trông như đang xoay trong không khí.
        ..scale(1, math.cos(p.flip * t * math.pi * 2).abs().clamp(0.15, 1.0));

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.width,
        height: p.height,
      );
      switch (p.shape) {
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.width / 2.4, paint);
        case _ConfettiShape.rect:
        case _ConfettiShape.strip:
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}

class _CelebrationCard extends StatelessWidget {
  final String emoji;
  final String? title;
  final String? message;

  const _CelebrationCard({required this.emoji, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    // Overlay không có Material bao ngoài nên tự thêm để chữ đúng theme.
    return Material(type: MaterialType.transparency, child: _buildCard());
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: MomTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MomTheme.pink),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332C2118),
            offset: Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFDCEBFA),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          if (title != null) ...[
            const SizedBox(height: 12),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: MomTheme.charcoal,
              ),
            ),
          ],
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: MomTheme.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
