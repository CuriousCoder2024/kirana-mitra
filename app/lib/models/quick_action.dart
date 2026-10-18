/// `quick_actions[]` entry. `action` ∈ undo | confirm | open_stock |
/// open_udhaar | open_forecast | send_order.
class QuickAction {
  const QuickAction({
    required this.label,
    required this.action,
    this.payload = const {},
  });

  final String label;
  final String action;
  final Map<String, dynamic> payload;

  String? get messageId => payload['message_id'] as String?;
  String? get whatsappUrl => payload['whatsapp_url'] as String?;

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
        label: json['label'] as String? ?? '',
        action: json['action'] as String? ?? '',
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'action': action,
        'payload': payload,
      };
}
