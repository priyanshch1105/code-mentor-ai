class ChatTurnResult {
  final String response;
  final int? sessionId;
  final String? sessionName;
  final String? subject;

  ChatTurnResult({
    required this.response,
    this.sessionId,
    this.sessionName,
    this.subject,
  });

  factory ChatTurnResult.fromJson(Map<String, dynamic> json) {
    return ChatTurnResult(
      response: json['response']?.toString() ?? '',
      sessionId: json['session_id'] is num ? (json['session_id'] as num).toInt() : null,
      sessionName: json['session_name']?.toString(),
      subject: json['subject']?.toString(),
    );
  }
}