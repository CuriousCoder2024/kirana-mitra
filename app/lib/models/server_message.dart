import 'quick_action.dart';

/// One server-generated bot message from GET /messages/{shop_id}.
class ServerMessage {
  const ServerMessage({
    required this.messageId,
    required this.createdAt,
    required this.replyText,
    this.quickActions = const [],
  });

  final String messageId;
  final String createdAt;
  final String replyText;
  final List<QuickAction> quickActions;

  factory ServerMessage.fromJson(Map<String, dynamic> j) => ServerMessage(
        messageId: j['message_id'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
        replyText: j['reply_text'] as String? ?? j['text'] as String? ?? '',
        quickActions: (j['quick_actions'] as List? ?? const [])
            .map((e) => QuickAction.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class MessagesResponse {
  const MessagesResponse({required this.messages});

  final List<ServerMessage> messages;

  factory MessagesResponse.fromJson(Map<String, dynamic> j) => MessagesResponse(
        messages: (j['messages'] as List? ?? const [])
            .map((e) => ServerMessage.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
