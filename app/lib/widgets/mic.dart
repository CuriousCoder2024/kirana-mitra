import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../state/mic_state.dart';
import '../theme/theme.dart';
import '../util/format.dart';

/// Max note length per the contract (60 s); the timer turns mirchi at 55 s.
const Duration kMaxNote = Duration(seconds: 60);
const Duration kWarnNote = Duration(seconds: 55);

/// Distance from the mic centre to the cancel target centre (§4.11).
const double kCancelOffset = 90;

/// Pointer handling for every mic: press starts, release sends, releasing
/// over the cancel target cancels, 60 s sends automatically.
class HoldToTalk extends ConsumerStatefulWidget {
  const HoldToTalk({
    super.key,
    required this.onStart,
    required this.onSend,
    required this.onCancel,
    required this.builder,
    this.prompt,
    this.enabled = true,
  });

  /// Returns false if recording could not start (no permission).
  final Future<bool> Function() onStart;
  final Future<void> Function(Duration elapsed) onSend;
  final Future<void> Function() onCancel;
  final Widget Function(BuildContext context, MicState state) builder;
  final String? prompt;
  final bool enabled;

  @override
  ConsumerState<HoldToTalk> createState() => _HoldToTalkState();
}

class _HoldToTalkState extends ConsumerState<HoldToTalk> {
  Offset? _downAt;
  DateTime? _startedAt;
  Timer? _tick;
  bool _active = false;
  bool _starting = false;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _down(PointerDownEvent e) async {
    if (!widget.enabled || _active || _starting) return;
    _starting = true;
    _downAt = e.position;
    final ok = await widget.onStart();
    _starting = false;
    if (!ok || !mounted || _downAt == null) return;
    _active = true;
    _startedAt = DateTime.now();
    ref.read(micStateProvider.notifier).start(prompt: widget.prompt);
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _startedAt == null) return;
      final elapsed = DateTime.now().difference(_startedAt!);
      ref.read(micStateProvider.notifier).tick(elapsed);
      if (elapsed >= kMaxNote) _finish(cancel: false);
    });
  }

  void _move(PointerMoveEvent e) {
    if (!_active || _downAt == null) return;
    final target = _downAt! + const Offset(-kCancelOffset, 0);
    final over = (e.position - target).distance < 40;
    if (over != ref.read(micStateProvider).cancelling) {
      ref.read(micStateProvider.notifier).cancelling(over);
    }
  }

  void _up(PointerEvent e) {
    if (_starting && !_active) {
      // Released before the recorder started: treat as cancelled.
      _downAt = null;
      return;
    }
    if (!_active) return;
    _finish(cancel: ref.read(micStateProvider).cancelling);
  }

  Future<void> _finish({required bool cancel}) async {
    if (!_active) return;
    _active = false;
    _tick?.cancel();
    final elapsed = _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);
    _startedAt = null;
    _downAt = null;
    ref.read(micStateProvider.notifier).stop();
    if (cancel) {
      await widget.onCancel();
    } else {
      await widget.onSend(elapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(micStateProvider);
    return Listener(
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _up,
      onPointerCancel: _up,
      behavior: HitTestBehavior.opaque,
      child: widget.builder(context, _active ? state : const MicState()),
    );
  }
}

/// The round mic itself: 80 dp saffron at rest, 92 dp terracotta with two
/// rings while recording, inkFaint with an X while over the cancel target.
class MicVisual extends StatelessWidget {
  const MicVisual({
    super.key,
    required this.state,
    required this.label,
    this.restSize = KmSize.micHero,
    this.enabled = true,
  });

  final MicState state;
  final String label;
  final double restSize;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final recording = state.recording;
    final size = recording ? KmSize.micRecording : restSize;
    final color = state.cancelling
        ? KmColors.inkFaint
        : recording
            ? KmColors.terracotta
            : enabled
                ? KmColors.saffron
                : KmColors.inkFaint;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: KmSize.micRecording + 44,
        height: KmSize.micRecording + 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (recording) ...[
              Container(
                width: size + 44,
                height: size + 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.08)),
              ),
              Container(
                width: size + 20,
                height: size + 20,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)),
              ),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: recording || !enabled ? null : KmShadow.micGlow,
              ),
              child: Icon(
                state.cancelling ? Icons.close_rounded : Icons.mic_rounded,
                color: KmColors.white,
                size: recording ? 44 : restSize / 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated 13-bar waveform for the recording sheet.
class RecordingWaveform extends StatefulWidget {
  const RecordingWaveform({super.key});

  @override
  State<RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<RecordingWaveform> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(13, (i) {
          final phase = animate ? _c.value * 2 * math.pi : 0.0;
          final base = 0.5 + 0.5 * math.sin(phase + i * 0.9);
          final h = 10 + 28 * (animate ? base : (i % 3 == 0 ? 0.9 : 0.4));
          return Container(
            width: 5,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(color: KmColors.terracotta, borderRadius: BorderRadius.circular(3)),
          );
        }),
      ),
    );
  }
}

/// The dashed 56 dp cancel target with an X.
class CancelTarget extends StatelessWidget {
  const CancelTarget({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: active ? KmColors.inkFaint : KmColors.sand),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Icon(Icons.close_rounded, size: 26, color: active ? KmColors.ink : KmColors.inkFaint),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final r = size.width / 2 - 1;
    final c = Offset(size.width / 2, size.height / 2);
    const segments = 14;
    for (var i = 0; i < segments; i++) {
      final start = (i / segments) * 2 * math.pi;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, math.pi / segments, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

/// Text block of the recording sheet: timer, waveform, label, cancel hint.
class RecordingReadout extends StatelessWidget {
  const RecordingReadout({super.key, required this.state});

  final MicState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final warn = state.elapsed >= kWarnNote;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.prompt != null) ...[
          Text(state.prompt!, style: KmText.bodySemi, textAlign: TextAlign.center),
          const SizedBox(height: 6),
        ],
        Text(
          Fmt.timer(state.elapsed),
          style: KmText.timer.copyWith(color: warn ? KmColors.mirchi : KmColors.terracotta),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 40, child: RecordingWaveform()),
        const SizedBox(height: 8),
        Text(
          state.cancelling ? l.recordingCancelled : l.recordingLabel,
          style: KmText.captionSemi.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, size: 18, color: KmColors.inkSoft),
            const SizedBox(width: 6),
            Text(l.recordingCancelHint, style: KmText.caption14Semi),
          ],
        ),
      ],
    );
  }
}

/// Handoff §4.11: the chat dock with the hero mic raised 30 dp above it, or
/// the recording sheet while pressed. The mic stays the same element in the
/// tree so the pointer stream survives the swap.
class MicDock extends ConsumerWidget {
  const MicDock({
    super.key,
    required this.onStart,
    required this.onSend,
    required this.onCancel,
    required this.onPhoto,
    required this.onType,
    this.enabled = true,
  });

  final Future<bool> Function() onStart;
  final Future<void> Function(Duration) onSend;
  final Future<void> Function() onCancel;
  final VoidCallback onPhoto;
  final VoidCallback onType;
  final bool enabled;

  static const double sheetHeight = 300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final recording = ref.watch(micStateProvider.select((s) => s.recording));
    const restHeight = KmSize.dock + KmSize.micRaise;
    final micBox = KmSize.micRecording + 44;

    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: recording ? sheetHeight : restHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Background: dock or sheet.
            Positioned(
              left: 0,
              right: 0,
              top: recording ? 0 : KmSize.micRaise,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: KmColors.paper,
                  border: Border(top: BorderSide(color: KmColors.sand)),
                ),
                child: recording
                    ? Consumer(
                        builder: (context, ref, _) => Padding(
                          padding: const EdgeInsets.only(top: 130),
                          child: RecordingReadout(state: ref.watch(micStateProvider)),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DockButton(icon: Icons.photo_camera_outlined, label: l.dockPhoto, onTap: enabled ? onPhoto : null),
                            const Spacer(),
                            _DockButton(icon: Icons.keyboard_alt_outlined, label: l.dockType, onTap: enabled ? onType : null),
                          ],
                        ),
                      ),
              ),
            ),
            if (recording)
              Positioned(
                top: 20 + (micBox - 56) / 2,
                left: MediaQuery.sizeOf(context).width / 2 - kCancelOffset - 28,
                child: Consumer(
                  builder: (context, ref, _) => CancelTarget(active: ref.watch(micStateProvider).cancelling),
                ),
              ),
            // Mic label under the hero mic (rest only).
            if (!recording)
              Positioned(
                top: KmSize.micHero + 6,
                child: Text(l.micLabel, style: KmText.micLabel),
              ),
            // The mic: same Stack slot in both states.
            Positioned(
              top: recording ? 20 : -(micBox - KmSize.micHero) / 2,
              child: HoldToTalk(
                enabled: enabled,
                onStart: onStart,
                onSend: onSend,
                onCancel: onCancel,
                builder: (context, state) => MicVisual(state: state, label: l.micLabel, enabled: enabled),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: KmColors.paper,
              shape: BoxShape.circle,
              border: Border.all(color: KmColors.sand, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Icon(icon, size: 26, color: onTap == null ? KmColors.inkFaint : KmColors.ink),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: KmText.status),
        ],
      ),
    );
  }
}

/// Handoff §4.11: 60 dp mic FAB on Stock, Udhaar and Forecast.
class MicFab extends ConsumerWidget {
  const MicFab({
    super.key,
    required this.onStart,
    required this.onSend,
    required this.onCancel,
    this.prompt,
    this.enabled = true,
  });

  final Future<bool> Function() onStart;
  final Future<void> Function(Duration) onSend;
  final Future<void> Function() onCancel;
  final String? prompt;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return HoldToTalk(
      enabled: enabled,
      prompt: prompt,
      onStart: onStart,
      onSend: onSend,
      onCancel: onCancel,
      builder: (context, state) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (state.recording)
            Positioned(
              left: (KmSize.micRecording + 44) / 2 - kCancelOffset - 28,
              child: CancelTarget(active: state.cancelling),
            ),
          MicVisual(state: state, label: l.micLabel, restSize: KmSize.micFab, enabled: enabled),
        ],
      ),
    );
  }
}

/// Bottom overlay shown on a tab while its FAB is held.
class RecordingOverlay extends ConsumerWidget {
  const RecordingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(micStateProvider);
    if (!state.recording) return const SizedBox.shrink();
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        decoration: const BoxDecoration(
          color: KmColors.paper,
          border: Border(top: BorderSide(color: KmColors.sand)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(KmRadius.sheet)),
        ),
        child: RecordingReadout(state: state),
      ),
    );
  }
}
