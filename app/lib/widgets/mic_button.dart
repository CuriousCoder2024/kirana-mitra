import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// 72 dp hold-to-record button. Press starts, release sends, sliding the
/// finger more than [cancelDistance] away cancels.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
    required this.holdLabel,
    required this.recordingLabel,
    required this.cancelLabel,
    this.enabled = true,
  });

  /// Returns false if recording could not start (e.g. no permission).
  final Future<bool> Function() onStart;
  final Future<void> Function() onStop;
  final Future<void> Function() onCancel;
  final String holdLabel;
  final String recordingLabel;
  final String cancelLabel;
  final bool enabled;

  static const double size = 72;
  static const double cancelDistance = 90;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool _recording = false;
  bool _cancelling = false;
  Offset? _downAt;
  DateTime? _startedAt;
  Timer? _tick;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _down(PointerDownEvent e) async {
    if (!widget.enabled || _recording) return;
    _downAt = e.position;
    _cancelling = false;
    final ok = await widget.onStart();
    if (!ok || !mounted) return;
    _startedAt = DateTime.now();
    setState(() {
      _recording = true;
      _elapsed = Duration.zero;
    });
    _tick = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || _startedAt == null) return;
      setState(() => _elapsed = DateTime.now().difference(_startedAt!));
    });
  }

  void _move(PointerMoveEvent e) {
    if (!_recording || _downAt == null) return;
    final far = (e.position - _downAt!).distance > MicButton.cancelDistance;
    if (far != _cancelling) setState(() => _cancelling = far);
  }

  Future<void> _up(PointerEvent e) async {
    if (!_recording) return;
    _tick?.cancel();
    final cancel = _cancelling;
    setState(() {
      _recording = false;
      _cancelling = false;
    });
    _startedAt = null;
    if (cancel) {
      await widget.onCancel();
    } else {
      await widget.onStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _cancelling
        ? KmColors.brownSoft
        : _recording
            ? KmColors.terracotta
            : KmColors.saffron;
    final label = _cancelling
        ? widget.cancelLabel
        : _recording
            ? '${widget.recordingLabel}  ${_fmt(_elapsed)}'
            : widget.holdLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _up,
          child: Semantics(
            button: true,
            label: widget.holdLabel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _recording ? MicButton.size + 12 : MicButton.size,
              height: _recording ? MicButton.size + 12 : MicButton.size,
              decoration: BoxDecoration(
                color: widget.enabled ? color : KmColors.creamDark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: _recording ? 0.45 : 0.25),
                    blurRadius: _recording ? 24 : 10,
                    spreadRadius: _recording ? 6 : 0,
                  ),
                ],
              ),
              child: Icon(
                _cancelling ? Icons.close_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _recording ? color : KmColors.brownSoft,
          ),
        ),
      ],
    );
  }

  static String _fmt(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(1, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
