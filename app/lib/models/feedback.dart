/// Response of POST /feedback and POST /feedback-voice.
class FeedbackReply {
  const FeedbackReply({required this.feedbackId, required this.replyText});

  final String feedbackId;
  final String replyText;

  factory FeedbackReply.fromJson(Map<String, dynamic> j) => FeedbackReply(
        feedbackId: j['feedback_id'] as String? ?? '',
        replyText: j['reply_text'] as String? ?? '',
      );
}
