import 'package:code_mentor_mobile/src/models/response/chat_turn_result.dart';
import 'package:code_mentor_mobile/src/models/response/session_summary.dart';

import '../models/repository.dart';

class ChatController {
  ChatController._();

  static final ChatController instance = ChatController._();

  final AppRepository _repository = AppRepository();

  Future<ChatTurnResult> sendMessage({
    required String prompt,
    String language = 'auto',
    int? sessionId,
    String? subject,
  }) async {
    final effectiveSubject = subject?.trim().isNotEmpty == true ? subject!.trim() : 'general';
    final effectiveSessionId = sessionId ?? await _repository.createChatSession(effectiveSubject);
    final response = await _repository.sendChatMessage(
      sessionId: effectiveSessionId,
      prompt: prompt,
    );
    return ChatTurnResult.fromJson({
      ...response,
      'session_id': effectiveSessionId,
      'subject': response['subject'] ?? effectiveSubject,
    });
  }

  Future<List<SessionSummary>> getSessions() {
    return _repository.fetchSessionSummaries();
  }

  Future<List<Map<String, dynamic>>> getMessages(
    int sessionId, {
    int page = 1,
    int limit = 10,
  }) {
    return _repository.fetchSessionMessages(
      sessionId,
      page: page,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getSession(int sessionId) {
    return _repository.fetchSessionDetail(sessionId);
  }

  Future<String> getRecommendation({String? subject}) {
    return _repository.fetchRecommendation(subject: subject);
  }

  Future<Map<String, dynamic>> getProgress() {
    return _repository.fetchProgress();
  }

  Future<List<Map<String, dynamic>>> getCodeSessions() {
    return _repository.fetchCodeSessions();
  }

  Future<Map<String, dynamic>> getCodeSession(int sessionId) {
    return _repository.fetchCodeSessionDetail(sessionId);
  }

  Future<Map<String, dynamic>> getQuizRecommendations() {
    return _repository.fetchQuizRecommendations();
  }

  Future<Map<String, dynamic>> getQuizHistory() {
    return _repository.fetchQuizHistory();
  }

  Future<Map<String, dynamic>> createQuiz({
    required String subject,
    String difficulty = 'beginner',
    String quizType = 'mixed',
    int totalQuestions = 5,
    int timeLimit = 600,
  }) {
    return _repository.createQuiz(
      subject: subject,
      difficulty: difficulty,
      quizType: quizType,
      totalQuestions: totalQuestions,
      timeLimit: timeLimit,
    );
  }

  Future<Map<String, dynamic>> getQuizQuestions(int quizId) {
    return _repository.fetchQuizQuestions(quizId);
  }

  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required List<Map<String, dynamic>> answers,
    int totalTimeTaken = 0,
  }) {
    return _repository.submitQuiz(
      quizId: quizId,
      answers: answers,
      totalTimeTaken: totalTimeTaken,
    );
  }
}
