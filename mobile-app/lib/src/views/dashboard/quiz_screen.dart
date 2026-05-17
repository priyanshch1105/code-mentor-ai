import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../widgets/section_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _loading = true;
  bool _creating = false;
  bool _submitting = false;
  String _subject = 'code tutor';
  String _difficulty = 'beginner';
  List<Map<String, dynamic>> _quizRecommendations = [];
  List<Map<String, dynamic>> _quizHistory = [];
  Map<String, dynamic>? _activeQuiz;
  List<Map<String, dynamic>> _questions = [];
  final Map<int, String> _answers = {};
  int _currentIndex = 0;
  Map<String, dynamic>? _result;

  String _normalizeSubject(String? subject) {
    final value = (subject ?? '').trim().toLowerCase();
    if (value.isEmpty || value == 'general' || value == 'code tutor') {
      return 'coding';
    }
    return value;
  }

  String _subjectDisplayLabel(String subject) {
    return subject == 'coding' ? 'CODE TUTOR' : subject.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final profile = await AuthController.instance.loadCurrentUser();
      final recommendations = await ChatController.instance
          .getQuizRecommendations();
      final history = await ChatController.instance.getQuizHistory();
      if (!mounted) return;
      setState(() {
        _subject = _normalizeSubject(profile.currentSubject);
        _quizRecommendations = List<Map<String, dynamic>>.from(
          recommendations['recommendations'] is List
              ? recommendations['recommendations'] as List
              : const [],
        );
        _quizHistory = List<Map<String, dynamic>>.from(
          history['quiz_history'] is List
              ? history['quiz_history'] as List
              : const [],
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshSidebarData() async {
    final recommendations = await ChatController.instance
        .getQuizRecommendations();
    final history = await ChatController.instance.getQuizHistory();
    if (!mounted) return;
    setState(() {
      _quizRecommendations = List<Map<String, dynamic>>.from(
        recommendations['recommendations'] is List
            ? recommendations['recommendations'] as List
            : const [],
      );
      _quizHistory = List<Map<String, dynamic>>.from(
        history['quiz_history'] is List
            ? history['quiz_history'] as List
            : const [],
      );
    });
  }

  Future<void> _createQuiz() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final quiz = await ChatController.instance.createQuiz(
        subject: _normalizeSubject(_subject),
        difficulty: _difficulty,
      );
      final quizId = quiz['quiz_id'] as int?;
      if (quizId == null) {
        throw Exception('Quiz id missing from response');
      }
      final questionsResponse = await ChatController.instance.getQuizQuestions(
        quizId,
      );
      if (!mounted) return;
      setState(() {
        _activeQuiz = quiz;
        _questions = List<Map<String, dynamic>>.from(
          questionsResponse['questions'] is List
              ? questionsResponse['questions'] as List
              : const [],
        );
        _answers.clear();
        _currentIndex = 0;
        _result = null;
      });
      await _refreshSidebarData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz create failed: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _submitQuiz() async {
    final quiz = _activeQuiz;
    if (quiz == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final answers = _questions.map((question) {
        final questionId = question['id'] as int;
        return {
          'question_id': questionId,
          'user_answer': _answers[questionId] ?? '',
          'time_taken': 0,
        };
      }).toList();

      final result = await ChatController.instance.submitQuiz(
        quizId: quiz['quiz_id'] as int,
        answers: answers,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
      });
      await _refreshSidebarData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz submit failed: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Map<String, dynamic>? get _currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start New Quiz',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetaBox(
                      label: 'Subject',
                      value: _subjectDisplayLabel(_subject),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetaBox(
                      label: 'Difficulty',
                      value: _difficulty.toUpperCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Code Tutor'),
                    selected: _normalizeSubject(_subject) == 'coding',
                    onSelected: (_) => setState(() => _subject = 'coding'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Beginner'),
                    selected: _difficulty == 'beginner',
                    onSelected: (_) => setState(() => _difficulty = 'beginner'),
                  ),
                  ChoiceChip(
                    label: const Text('Intermediate'),
                    selected: _difficulty == 'intermediate',
                    onSelected: (_) =>
                        setState(() => _difficulty = 'intermediate'),
                  ),
                  ChoiceChip(
                    label: const Text('Advanced'),
                    selected: _difficulty == 'advanced',
                    onSelected: (_) => setState(() => _difficulty = 'advanced'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _creating ? null : _createQuiz,
                icon: _creating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.quiz_outlined),
                label: const Text('Create Quiz'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _creating
                    ? null
                    : () async {
                        // create a local mock quiz for testing without backend
                        setState(() => _creating = true);
                        try {
                          final mockQuiz = {
                            'quiz_id': -1,
                            'title': 'Code Tutor — Test Quiz',
                            'total_questions': 3,
                            'time_limit': 600,
                          };
                          final mockQuestions = [
                            {
                              'id': 1001,
                              'question_text': 'What does HTTP stand for?',
                              'options': [
                                'HyperText Transfer Protocol',
                                'Hyperlink Transfer Protocol',
                                'HyperText Transmission Protocol',
                              ],
                            },
                            {
                              'id': 1002,
                              'question_text':
                                  'Which language is primarily used for Flutter?',
                              'options': ['Dart', 'Kotlin', 'Swift'],
                            },
                            {
                              'id': 1003,
                              'question_text':
                                  'Explain what a promise is in JavaScript.',
                              'options': [],
                            },
                          ];
                          if (!mounted) return;
                          setState(() {
                            _activeQuiz = mockQuiz;
                            _questions = List<Map<String, dynamic>>.from(
                              mockQuestions,
                            );
                            _answers.clear();
                            _currentIndex = 0;
                            _result = null;
                          });
                        } finally {
                          if (mounted) setState(() => _creating = false);
                        }
                      },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Use Test Data'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_activeQuiz != null && _currentQuestion != null)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _activeQuiz!['title']?.toString() ?? 'Active Quiz',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text('${_currentIndex + 1}/${_questions.length}'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                Text(
                  _currentQuestion!['question_text']?.toString() ?? '',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...List<String>.from(
                  _currentQuestion!['options'] is List
                      ? _currentQuestion!['options'] as List
                      : const [],
                ).map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OptionCard(
                      text: option,
                      selected:
                          _answers[_currentQuestion!['id'] as int] == option,
                      onTap: () => setState(
                        () => _answers[_currentQuestion!['id'] as int] = option,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _currentIndex == 0
                          ? null
                          : () => setState(() => _currentIndex -= 1),
                      child: const Text('Previous'),
                    ),
                    const Spacer(),
                    if (_currentIndex < _questions.length - 1)
                      FilledButton(
                        onPressed: () => setState(() => _currentIndex += 1),
                        child: const Text('Next'),
                      )
                    else
                      FilledButton(
                        onPressed: _submitting ? null : _submitQuiz,
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        if (_result != null) ...[
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Result',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${_result!['percentage']?.toString() ?? '--'}% score'),
                const SizedBox(height: 4),
                Text(_result!['message']?.toString() ?? ''),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_quizRecommendations.isEmpty)
                Text(
                  'Complete quizzes to get personalized recommendations.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ..._quizRecommendations.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RecommendationItem(
                      title:
                          '${item['subject']?.toString() ?? 'Quiz'} • ${item['difficulty']?.toString() ?? 'beginner'}',
                      subtitle: item['reason']?.toString() ?? '',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_quizHistory.isEmpty)
                Text('No quiz attempts yet.', style: theme.textTheme.bodyMedium)
              else
                ..._quizHistory.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry['title']?.toString() ?? 'Quiz'),
                    subtitle: Text(
                      '${entry['subject']?.toString() ?? 'code tutor'} • ${entry['percentage']?.toString() ?? '--'}%',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaBox extends StatelessWidget {
  const _MetaBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.text, this.selected = false, this.onTap});

  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.09)
              : null,
        ),
        child: Text(text),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  const _RecommendationItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
