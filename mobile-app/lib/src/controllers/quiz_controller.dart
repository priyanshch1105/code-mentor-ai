import 'package:code_mentor_mobile/src/controllers/chat_controller.dart';

class QuizController {
  QuizController._();

  static final QuizController instance = QuizController._();

  final _chat = ChatController.instance;

  Future<Map<String, dynamic>> getRecommendations() {
    return _chat.getQuizRecommendations();
  }

  Future<Map<String, dynamic>> getHistory() {
    return _chat.getQuizHistory();
  }

  Future<Map<String, dynamic>> createQuiz({
    required String subject,
    String difficulty = 'beginner',
    String quizType = 'mixed',
    int totalQuestions = 5,
    int timeLimit = 600,
  }) {
    return _chat.createQuiz(
      subject: subject,
      difficulty: difficulty,
      quizType: quizType,
      totalQuestions: totalQuestions,
      timeLimit: timeLimit,
    );
  }

  Future<Map<String, dynamic>> getQuestions(int quizId) {
    return _chat.getQuizQuestions(quizId);
  }

  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required List<Map<String, dynamic>> answers,
    int totalTimeTaken = 0,
  }) {
    return _chat.submitQuiz(
      quizId: quizId,
      answers: answers,
      totalTimeTaken: totalTimeTaken,
    );
  }
}
