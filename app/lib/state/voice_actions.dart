import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'chat_controller.dart';
import 'voice_recorder.dart';

/// Start / send / cancel for any hold-to-talk mic. Owns one recorder.
class VoiceActions {
  VoiceActions(this.ref);

  final WidgetRef ref;
  final VoiceRecorder _recorder = VoiceRecorder();

  void dispose() => _recorder.dispose();

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<bool> start(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      if (!await _recorder.hasPermission()) {
        if (context.mounted) _snack(context, l.micPermissionDenied);
        return false;
      }
      await _recorder.start();
      return true;
    } catch (_) {
      if (context.mounted) _snack(context, l.micPermissionDenied);
      return false;
    }
  }

  /// Stops and sends. When [float] is true (tab FABs) the reply also shows
  /// as a floating card on that tab for six seconds.
  Future<void> send(BuildContext context, Duration elapsed, {bool float = false}) async {
    final l = AppLocalizations.of(context);
    final tooShort = elapsed < const Duration(milliseconds: 600);
    final blob = await (() async {
      try {
        return await _recorder.stop();
      } catch (_) {
        return null;
      }
    })();
    if (tooShort || blob == null) {
      if (context.mounted) _snack(context, l.voiceTooShort);
      return;
    }
    final reply = await ref.read(chatControllerProvider.notifier).sendVoice(blob, duration: elapsed);
    if (float && reply != null) {
      final messages = ref.read(chatControllerProvider).messages;
      final card = messages.where((m) => m.id == reply.messageId).lastOrNull ?? messages.last;
      ref.read(floatingReplyProvider.notifier).show(card);
    }
  }

  Future<void> cancel(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await _recorder.cancel();
    if (context.mounted) _snack(context, l.recordingCancelled);
  }
}
