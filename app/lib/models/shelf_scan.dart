import 'quick_action.dart';

class ScannedItem {
  const ScannedItem({
    required this.name,
    required this.count,
    required this.confidence,
    this.packSize,
  });

  final String name;
  final String? packSize;
  final num count;
  final double confidence;

  factory ScannedItem.fromJson(Map<String, dynamic> json) => ScannedItem(
        name: json['name'] as String? ?? '',
        packSize: json['pack_size'] as String?,
        count: json['count'] as num? ?? 0,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'pack_size': packSize,
        'count': count,
        'confidence': confidence,
      };
}

class ScanLowStock {
  const ScanLowStock({
    required this.name,
    required this.count,
    required this.reorderLevel,
  });

  final String name;
  final num count;
  final num reorderLevel;

  factory ScanLowStock.fromJson(Map<String, dynamic> json) => ScanLowStock(
        name: json['name'] as String? ?? '',
        count: json['count'] as num? ?? 0,
        reorderLevel: json['reorder_level'] as num? ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'count': count, 'reorder_level': reorderLevel};
}

/// A product seen on the shelf that is not in the catalogue.
class UnmatchedItem {
  const UnmatchedItem({required this.name, required this.count});

  final String name;
  final num count;

  factory UnmatchedItem.fromJson(Map<String, dynamic> json) => UnmatchedItem(
        name: json['name'] as String? ?? '',
        count: json['count'] as num? ?? 0,
      );

  Map<String, dynamic> toJson() => {'name': name, 'count': count};
}

/// Response of POST /shelf-scan.
class ShelfScanResponse {
  const ShelfScanResponse({
    required this.messageId,
    required this.items,
    required this.lowStock,
    required this.replyText,
    this.quickActions = const [],
    this.unmatched = const [],
  });

  final String messageId;
  final List<ScannedItem> items;
  final List<ScanLowStock> lowStock;
  final String replyText;
  final List<QuickAction> quickActions;
  final List<UnmatchedItem> unmatched;

  factory ShelfScanResponse.fromJson(Map<String, dynamic> json) =>
      ShelfScanResponse(
        messageId: json['message_id'] as String? ?? '',
        items: (json['items'] as List? ?? const [])
            .map((e) => ScannedItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        lowStock: (json['low_stock'] as List? ?? const [])
            .map((e) =>
                ScanLowStock.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        replyText: json['reply_text'] as String? ?? '',
        quickActions: (json['quick_actions'] as List? ?? const [])
            .map((e) => QuickAction.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        unmatched: (json['unmatched'] as List? ?? const [])
            .map((e) => UnmatchedItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'items': items.map((e) => e.toJson()).toList(),
        'low_stock': lowStock.map((e) => e.toJson()).toList(),
        'reply_text': replyText,
        'quick_actions': quickActions.map((e) => e.toJson()).toList(),
        'unmatched': unmatched.map((e) => e.toJson()).toList(),
      };
}
