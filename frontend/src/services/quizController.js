import api from './api';

const QuizController = {
  async getRecommendations() {
    const res = await api.get('/api/quiz/recommendations');
    return res.data;
  },

  async getHistory() {
    const res = await api.get('/api/quiz/history');
    return res.data;
  },

  async createQuiz({ subject = 'code tutor', difficulty = 'beginner', quizType = 'mixed', totalQuestions = 5, timeLimit = 600 } = {}) {
    const res = await api.post('/api/quiz/create', {
      subject,
      difficulty,
      quiz_type: quizType,
      total_questions: totalQuestions,
      time_limit: timeLimit,
    });
    return res.data;
  },

  async getQuestions(quizId) {
    const res = await api.get(`/api/quiz/${quizId}/questions`);
    return res.data;
  },

  async submitQuiz({ quizId, answers = [], totalTimeTaken = 0 }) {
    const res = await api.post('/api/quiz/submit', {
      quiz_id: quizId,
      answers,
      total_time_taken: totalTimeTaken,
    });
    return res.data;
  }
};

export default QuizController;
