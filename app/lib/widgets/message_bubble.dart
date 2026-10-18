import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/chat_controller.dart';
import '../theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.onAction,
  });

  final ChatMessage message;
  final void Function(QuickAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final bg = message.isError
        ? const Color(0xFFFFF0EE)
        : isUser
            ? KmColors.userBubble
            : KmColors.botBubble;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 20),
    );
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
                border: Border.all(
                  color: message.isError ? const Color(0xFFF3B8B0) : KmColors.creamDark,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.imageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message.imageBytes!,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (message.transcript != null && message.transcript!.isNotEmpty) ...[
                    Text(
                      '"${message.transcript}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: KmColors.brownSoft,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.35,
                      color: message.isError ? const Color(0xFF8A2A1F) : KmColors.brown,
                    ),
                  ),
                ],
              ),
            ),
            if (message.quickActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in message.quickActions)
                      ActionChip(
                        label: Text(a.label),
                        avatar: Icon(_iconFor(a.action), size: 20, color: KmColors.terracotta),
                        onPressed: () => onAction(a),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(String action) => switch (action) {
        'undo' => Icons.undo_rounded,
        'confirm' => Icons.check_circle_outline_rounded,
        'open_stock' => Icons.inventory_2_outlined,
        'open_udhaar' => Icons.account_balance_wallet_outlined,
        'open_forecast' => Icons.trending_up_rounded,
        'send_order' => Icons.send_rounded,
        _ => Icons.touch_app_outlined,
      };
}
