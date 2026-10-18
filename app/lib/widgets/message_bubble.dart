import 'package:flutter/material.dart';

import '../state/chat_controller.dart';
import '../theme/theme.dart';
import '../util/format.dart';

/// Handoff §4.4: text, voice and photo bubbles. Reply cards live in
/// reply_card.dart.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.voiceLabel,
  });

  final ChatMessage message;

  /// Shown while a voice note has no transcript yet.
  final String voiceLabel;

  static const double maxWidth = 300;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(isUser ? KmRadius.card : KmRadius.bubbleTight),
      topRight: Radius.circular(isUser ? KmRadius.bubbleTight : KmRadius.card),
      bottomLeft: const Radius.circular(KmRadius.card),
      bottomRight: const Radius.circular(KmRadius.card),
    );

    Widget child;
    if (message.kind == ChatKind.photo && message.imageBytes != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(message.imageBytes!, width: 200, height: 130, fit: BoxFit.cover),
      );
    } else {
      final text = message.kind == ChatKind.voice && message.text.isEmpty ? voiceLabel : message.text;
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: KmText.body.copyWith(
              color: message.isError ? KmColors.mirchi : KmColors.ink,
              fontStyle: message.kind == ChatKind.voice && message.text.isEmpty ? FontStyle.italic : null,
            ),
          ),
          if (message.kind == ChatKind.voice) ...[
            const SizedBox(height: 6),
            _VoiceMeta(duration: message.audioDuration ?? Duration.zero),
          ],
        ],
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: message.kind == ChatKind.photo
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? KmColors.saffronTint : KmColors.paper,
            borderRadius: radius,
            border: isUser ? null : Border.all(color: message.isError ? KmColors.mirchiBorder : KmColors.sand),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 16 dp mic icon, a 7-bar static waveform and the duration.
class _VoiceMeta extends StatelessWidget {
  const _VoiceMeta({required this.duration});

  final Duration duration;

  static const _heights = [10.0, 18.0, 22.0, 14.0, 20.0, 12.0, 8.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mic_rounded, size: 16, color: KmColors.saffron),
        const SizedBox(width: 6),
        for (final h in _heights)
          Container(
            width: 3,
            height: h,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(color: KmColors.saffron, borderRadius: BorderRadius.circular(2)),
          ),
        const SizedBox(width: 6),
        Text(Fmt.timer(duration), style: KmText.meta),
      ],
    );
  }
}
