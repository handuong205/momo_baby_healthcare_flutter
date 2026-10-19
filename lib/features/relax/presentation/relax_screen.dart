import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/mom_ui.dart';

class _Track {
  const _Track(this.title, this.subtitle, this.asset, this.icon, this.color);

  final String title;
  final String subtitle;
  final String asset;
  final IconData icon;
  final Color color;
}

const _tracks = [
  _Track(
    'Ru con',
    'Hộp nhạc nhẹ nhàng giúp bé dễ ngủ',
    'audio/lullaby.wav',
    LucideIcons.music,
    Color(0xFFB85B7A),
  ),
  _Track(
    'Tiếng ồn trắng',
    'Giống âm thanh trong bụng mẹ, bé bớt quấy',
    'audio/white_noise.wav',
    LucideIcons.wind,
    Color(0xFF4A88C7),
  ),
  _Track(
    'Mưa rơi',
    'Tiếng mưa đều đều giúp mẹ thư thái',
    'audio/rain.wav',
    LucideIcons.cloudRain,
    Color(0xFF5F7A6B),
  ),
  _Track(
    'Sóng biển',
    'Nhịp sóng chậm giúp hít thở sâu hơn',
    'audio/ocean.wav',
    LucideIcons.waves,
    Color(0xFF8E6BB8),
  ),
];

const _timerOptions = [0, 15, 30, 60];

/// (15) Thư giãn — nhạc thư giãn phát qua loa, hẹn giờ tắt và bài tập thở.
class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  final player = AudioPlayer(playerId: 'relax');
  StreamSubscription<PlayerState>? _stateSub;
  _Track? current;
  bool playing = false;
  double volume = 0.7;
  int timerMinutes = 0;
  Timer? _sleepTimer;
  DateTime? _stopAt;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    player.setReleaseMode(ReleaseMode.loop);
    player.setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.gain,
        stayAwake: true,
      ).build(),
    );
    _stateSub = player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => playing = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _ticker?.cancel();
    _stateSub?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> toggle(_Track track) async {
    if (current == track && playing) {
      await player.pause();
      return;
    }
    if (current == track) {
      await player.resume();
    } else {
      setState(() => current = track);
      await player.stop();
      await player.play(AssetSource(track.asset), volume: volume);
    }
    _armTimer();
  }

  Future<void> stop() async {
    await player.stop();
    _sleepTimer?.cancel();
    _ticker?.cancel();
    setState(() {
      current = null;
      _stopAt = null;
    });
  }

  void setTimer(int minutes) {
    setState(() => timerMinutes = minutes);
    _armTimer();
  }

  void _armTimer() {
    _sleepTimer?.cancel();
    _ticker?.cancel();
    if (timerMinutes == 0 || current == null) {
      setState(() => _stopAt = null);
      return;
    }
    final duration = Duration(minutes: timerMinutes);
    _stopAt = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, stop);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  String? get _remaining {
    final stopAt = _stopAt;
    if (stopAt == null) return null;
    final left = stopAt.difference(DateTime.now());
    if (left.isNegative) return null;
    final m = left.inMinutes.toString().padLeft(2, '0');
    final s = (left.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) => MomScreen(
    eyebrow: 'Tiện ích & an toàn',
    title: 'Thư giãn',
    subtitle: 'Một phút cho riêng mẹ. Nhạc phát qua loa, có hẹn giờ tắt.',
    children: [
      const _BreathingCard(),
      const MomSectionTitle(
        title: 'Nhạc thư giãn',
        subtitle: 'Giúp mẹ thư thái và bé dễ ngủ',
      ),
      ..._tracks.map(
        (t) => _TrackTile(
          track: t,
          active: current == t,
          playing: current == t && playing,
          onTap: () => toggle(t),
        ),
      ),
      if (current != null)
        _PlayerPanel(
          track: current!,
          playing: playing,
          volume: volume,
          timerMinutes: timerMinutes,
          remaining: _remaining,
          onToggle: () => toggle(current!),
          onStop: stop,
          onVolume: (v) {
            setState(() => volume = v);
            player.setVolume(v);
          },
          onTimer: setTimer,
        ),
    ],
  );
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.active,
    required this.playing,
    required this.onTap,
  });

  final _Track track;
  final bool active;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: active ? MomTheme.pinkLight : MomTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MomTheme.radiusCard),
        side: BorderSide(
          color: active ? MomTheme.roseDark : MomTheme.borderSoft,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(MomTheme.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: track.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(track.icon, size: 18, color: track.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        color: MomTheme.charcoal,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.subtitle,
                      style: const TextStyle(
                        color: MomTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                playing ? LucideIcons.circlePause : LucideIcons.circlePlay,
                size: 30,
                color: MomTheme.roseDark,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.track,
    required this.playing,
    required this.volume,
    required this.timerMinutes,
    required this.remaining,
    required this.onToggle,
    required this.onStop,
    required this.onVolume,
    required this.onTimer,
  });

  final _Track track;
  final bool playing;
  final double volume;
  final int timerMinutes;
  final String? remaining;
  final VoidCallback onToggle;
  final VoidCallback onStop;
  final ValueChanged<double> onVolume;
  final ValueChanged<int> onTimer;

  @override
  Widget build(BuildContext context) => MomCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Đang phát: ${track.title}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: MomTheme.charcoal,
                ),
              ),
            ),
            IconButton.filled(
              onPressed: onToggle,
              style: IconButton.styleFrom(backgroundColor: MomTheme.roseDark),
              icon: Icon(playing ? LucideIcons.pause : LucideIcons.play),
            ),
            IconButton(
              tooltip: 'Dừng',
              onPressed: onStop,
              icon: const Icon(LucideIcons.square),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(LucideIcons.volume1, size: 18, color: MomTheme.muted),
            Expanded(
              child: Slider(
                value: volume,
                onChanged: onVolume,
                activeColor: MomTheme.roseDark,
              ),
            ),
            const Icon(LucideIcons.volume2, size: 18, color: MomTheme.muted),
          ],
        ),
        Row(
          children: [
            const Icon(LucideIcons.timer, size: 16, color: MomTheme.muted),
            const SizedBox(width: 6),
            Text(
              remaining == null ? 'Hẹn giờ tắt' : 'Tắt sau $remaining',
              style: const TextStyle(fontSize: 13, color: MomTheme.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timerOptions
              .map(
                (m) => MomChip(
                  label: m == 0 ? 'Không' : '$m phút',
                  selected: timerMinutes == m,
                  onTap: () => onTimer(m),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

/// Bài tập thở 4-2-6: hít vào 4 giây, giữ 2 giây, thở ra 6 giây.
class _BreathingCard extends StatefulWidget {
  const _BreathingCard();

  @override
  State<_BreathingCard> createState() => _BreathingCardState();
}

class _BreathingCardState extends State<_BreathingCard>
    with SingleTickerProviderStateMixin {
  static const _inhale = 4, _hold = 2, _exhale = 6, _rounds = 5;
  static const _cycle = _inhale + _hold + _exhale;

  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _cycle * _rounds),
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    if (controller.isAnimating) {
      controller.reset();
    } else {
      controller.forward(from: 0);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = controller.value * _cycle * _rounds;
    final running = controller.isAnimating;
    final round = (elapsed ~/ _cycle) + 1;
    final t = elapsed % _cycle;

    String phase;
    double scale;
    int secondsLeft;
    if (!running) {
      phase = controller.isCompleted ? 'Hoàn thành 🌸' : 'Sẵn sàng';
      scale = 0.6;
      secondsLeft = 0;
    } else if (t < _inhale) {
      phase = 'Hít vào';
      scale = 0.6 + 0.4 * (t / _inhale);
      secondsLeft = (_inhale - t).ceil();
    } else if (t < _inhale + _hold) {
      phase = 'Giữ hơi';
      scale = 1;
      secondsLeft = (_inhale + _hold - t).ceil();
    } else {
      phase = 'Thở ra';
      scale = 1 - 0.4 * ((t - _inhale - _hold) / _exhale);
      secondsLeft = (_cycle - t).ceil();
    }

    return MomCard(
      color: MomTheme.sageLight,
      borderColor: MomTheme.sageLight,
      shadow: const [],
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Text(
            'Bài tập 1 phút',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MomTheme.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hít vào 4 giây, giữ 2 giây, thở ra 6 giây. Lặp lại 5 lần.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: MomTheme.muted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 170,
            height: 170,
            child: Center(
              child: Container(
                width: 170 * scale,
                height: 170 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MomTheme.sage.withValues(alpha: 0.35),
                  border: Border.all(color: MomTheme.sageDark, width: 2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      phase,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: MomTheme.sageDark,
                      ),
                    ),
                    if (running)
                      Text(
                        '$secondsLeft',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: MomTheme.sageDark,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (running)
            Text(
              'Lần $round/$_rounds',
              style: const TextStyle(fontSize: 12, color: MomTheme.muted),
            ),
          const SizedBox(height: 10),
          MomPrimaryButton(
            label: running ? 'Dừng' : 'Bắt đầu',
            icon: running ? LucideIcons.square : LucideIcons.play,
            color: MomTheme.sageDark,
            onPressed: toggle,
          ),
        ],
      ),
    );
  }
}
