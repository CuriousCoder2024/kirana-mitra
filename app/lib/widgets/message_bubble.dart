import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/chat_controller.dart';
import '../theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.onAction,
    required this.lowLabel,
    required this.colItem,
    required this.colPack,
    required this.colCount,
  });

  final ChatMessage message;
  final void Function(QuickAction action) onAction;
  final String lowLabel;
  final String colItem;
  final String colPack;
  final String colCount;

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
                  if (message.scanItems.isNotEmpty) ...[
                    _ScanTable(
                      items: message.scanItems,
                      low: message.scanLowStock,
                      lowLabel: lowLabel,
                      colItem: colItem,
                      colPack: colPack,
                      colCount: colCount,
                    ),
                    const SizedBox(height: 10),
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

/// Compact table of what the shelf scan saw.
class _ScanTable extends StatelessWidget {
  const _ScanTable({
    required this.items,
    required this.low,
    required this.lowLabel,
    required this.colItem,
    required this.colPack,
    required this.colCount,
  });

  final List<ScannedItem> items;
  final Set<String> low;
  final String lowLabel;
  final String colItem;
  final String colPack;
  final String colCount;

  @override
  Widget build(BuildContext context) {
    const head = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: KmColors.brownSoft);
    const cell = TextStyle(fontSize: 16, color: KmColors.brown);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KmColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KmColors.creamDark),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1.6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(colItem, style: head)),
            Text(colPack, style: head),
            Text(colCount, style: head, textAlign: TextAlign.right),
          ]),
          for (final it in items)
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(it.name, style: cell.copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(it.packSize ?? '-', style: cell),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (low.contains(it.name))
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: KmColors.alert,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        lowLabel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  Text(
                    _n(it.count),
                    style: cell.copyWith(
                      fontWeight: FontWeight.w700,
                      color: low.contains(it.name) ? KmColors.alert : KmColors.brown,
                    ),
                  ),
                ],
              ),
            ]),
        ],
      ),
    );
  }

  static String _n(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
}
