import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared recording state so the chat list can dim and the tab screens can
/// show the recording sheet while the finger is on a mic (handoff §4.11).
class MicState {
  const MicState({
    this.recording = false,
    this.cancelling = false,
    this.elapsed = Duration.zero,
    this.prompt,
  });

  final bool recording;
  final bool cancelling;
  final Duration elapsed;

  /// Optional prompt shown on the sheet, e.g. "Kitna aaya? Bolo."
  final String? prompt;

  MicState copyWith({bool? recording, bool? cancelling, Duration? elapsed, String? prompt}) => MicState(
        recording: recording ?? this.recording,
        cancelling: cancelling ?? this.cancelling,
        elapsed: elapsed ?? this.elapsed,
        prompt: prompt ?? this.prompt,
      );
}

class MicStateNotifier extends Notifier<MicState> {
  @override
  MicState build() => const MicState();

  void start({String? prompt}) => state = MicState(recording: true, prompt: prompt);
  void tick(Duration elapsed) => state = state.copyWith(elapsed: elapsed);
  void cancelling(bool v) => state = state.copyWith(cancelling: v);
  void stop() => state = const MicState();
}

final micStateProvider = NotifierProvider<MicStateNotifier, MicState>(MicStateNotifier.new);
