class CodeDebugResult {
  final int sessionId;
  final String response;
  final String? responseRoman;
  final String sessionName;
  final bool hasError;
  final String? errorMessage;

  CodeDebugResult({
    required this.sessionId,
    required this.response,
    required this.sessionName,
    required this.hasError,
    this.responseRoman,
    this.errorMessage,
  });

  factory CodeDebugResult.fromJson(Map<String, dynamic> json) {
    return CodeDebugResult(
      sessionId: json['session_id'] ?? 0,
      response: json['response'] ?? '',
      responseRoman: json['response_roman'] as String?,
      sessionName: json['session_name'] ?? '',
      hasError: json['has_error'] ?? false,
      errorMessage: json['error_message'] as String?,
    );
  }
}
