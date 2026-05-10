class QaResult {
  final String response;
  final int? sessionId;
  final String? sessionName;

  QaResult({required this.response, this.sessionId, this.sessionName});

  factory QaResult.fromJson(Map<String, dynamic> json) {
    return QaResult(
      response: json['response'] ?? '',
      sessionId: json['session_id'] is int ? json['session_id'] : null,
      sessionName: json['session_name'] as String?,
    );
  }
}
