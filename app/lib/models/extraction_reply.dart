import 'quick_action.dart';

class EntityItem {
  const EntityItem({
    required this.name,
    this.packSize,
    this.quantity,
    this.unit,
    this.unitPrice,
  });

  final String name;
  final String? packSize;
  final num? quantity;
  final String? unit;
  final num? unitPrice;

  factory EntityItem.fromJson(Map<String, dynamic> json) => EntityItem(
        name: json['name'] as String? ?? '',
        packSize: json['pack_size'] as String?,
        quantity: json['quantity'] as num?,
        unit: json['unit'] as String?,
        unitPrice: json['unit_price'] as num?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'pack_size': packSize,
        'quantity': quantity,
        'unit': unit,
        'unit_price': unitPrice,
      };
}

class Entities {
  const Entities({
    this.items = const [],
    this.customerName,
    this.amount,
    this.date,
  });

  final List<EntityItem> items;
  final String? customerName;
  final num? amount;
  final String? date;

  factory Entities.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Entities();
    return Entities(
      items: (json['items'] as List? ?? const [])
          .map((e) => EntityItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      customerName: json['customer_name'] as String?,
      amount: json['amount'] as num?,
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'customer_name': customerName,
        'amount': amount,
        'date': date,
      };
}

/// Response of POST /chat, /voice-note and /confirm.
class ExtractionReply {
  const ExtractionReply({
    required this.messageId,
    required this.intent,
    required this.confidence,
    required this.language,
    required this.entities,
    required this.applied,
    required this.replyText,
    this.transcript,
    this.quickActions = const [],
  });

  final String messageId;

  /// stock_in | sale | udhaar_given | udhaar_paid | question | unclear
  final String intent;
  final double confidence;
  final String? transcript;
  final String language;
  final Entities entities;
  final bool applied;
  final String replyText;
  final List<QuickAction> quickActions;

  factory ExtractionReply.fromJson(Map<String, dynamic> json) =>
      ExtractionReply(
        messageId: json['message_id'] as String? ?? '',
        intent: json['intent'] as String? ?? 'unclear',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
        transcript: json['transcript'] as String?,
        language: json['language'] as String? ?? 'hi-Latn',
        entities:
            Entities.fromJson((json['entities'] as Map?)?.cast<String, dynamic>()),
        applied: json['applied'] as bool? ?? false,
        replyText: json['reply_text'] as String? ?? '',
        quickActions: (json['quick_actions'] as List? ?? const [])
            .map((e) => QuickAction.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'intent': intent,
        'confidence': confidence,
        'transcript': transcript,
        'language': language,
        'entities': entities.toJson(),
        'applied': applied,
        'reply_text': replyText,
        'quick_actions': quickActions.map((e) => e.toJson()).toList(),
      };
}

/// Response of POST /undo.
class UndoReply {
  const UndoReply({required this.undone, required this.replyText});

  final bool undone;
  final String replyText;

  factory UndoReply.fromJson(Map<String, dynamic> json) => UndoReply(
        undone: json['undone'] as bool? ?? false,
        replyText: json['reply_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'undone': undone, 'reply_text': replyText};
}
