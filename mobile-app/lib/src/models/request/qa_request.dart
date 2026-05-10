class QaRequest {
  final String prompt;
  final String language;
  final int? sessionId;

  QaRequest({
    required this.prompt,
    this.language = 'auto',
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'language': language,
        if (sessionId != null) 'session_id': sessionId,
      };
}
