import '../models/repository.dart';

class ChatController {
  ChatController._();

  static final ChatController instance = ChatController._();

  final AppRepository _repository = AppRepository();

  Future<QaResult> sendMessage({
    required String prompt,
    String language = 'auto',
    int? sessionId,
  }) {
    return _repository.askQuestion(
      QaRequest(prompt: prompt, language: language, sessionId: sessionId),
    );
  }

  Future<List<SessionSummary>> getSessions() {
    return _repository.fetchSessions();
  }

  Future<String> getRecommendation({String? subject}) {
    return _repository.fetchRecommendation(subject: subject);
  }

  Future<Map<String, dynamic>> getProgress() {
    return _repository.fetchProgress();
  }
}
