import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../utils/theme_utils.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String _subject = 'code tutor';
  Map<String, dynamic> _progress = {};
  Map<String, dynamic> _recommendation = {};
  List<Map<String, dynamic>> _quizHistory = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final profile = await AuthController.instance.loadCurrentUser();
      final progressResponse = await ChatController.instance.getProgress();
      final recommendation = await ChatController.instance
          .getQuizRecommendations();
      final quizHistory = await ChatController.instance.getQuizHistory();
      if (!mounted) return;
      setState(() {
        _subject = profile.currentSubject;
        _progress = Map<String, dynamic>.from(
          progressResponse['progress'] is Map
              ? progressResponse['progress'] as Map
              : {},
        );
        _recommendation = Map<String, dynamic>.from(recommendation);
        _quizHistory = List<Map<String, dynamic>>.from(
          quizHistory['quiz_history'] is List
              ? quizHistory['quiz_history'] as List
              : const [],
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double _averageProgress() {
    final values = _progress.values
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a + b) / values.length / 100).clamp(0, 1);
  }

  String _formatQuizPercent(dynamic value) {
    if (value is num) {
      return '${value.toStringAsFixed(0)}%';
    }
    final parsed = double.tryParse(value?.toString() ?? '');
    return parsed == null ? '--' : '${parsed.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ThemeUtils.getColors(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final recentQuiz = _quizHistory.isNotEmpty ? _quizHistory.first : null;
    final progressCount = _progress.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _StatCard(
              label: 'Subjects',
              value: '$progressCount',
              color: colors.primary,
              icon: Icons.menu_book,
            ),
            _StatCard(
              label: 'Average',
              value: '${(_averageProgress() * 100).toStringAsFixed(0)}%',
              color: colors.success,
              icon: Icons.trending_up,
            ),
            _StatCard(
              label: 'Recent Quiz',
              value: recentQuiz == null
                  ? '--'
                  : _formatQuizPercent(recentQuiz['percentage']),
              color: colors.warning,
              icon: Icons.quiz,
            ),
            _StatCard(
              label: 'Current',
              value: (_subject == 'general' ? 'code tutor' : _subject)
                  .toUpperCase(),
              color: colors.secondary,
              icon: Icons.access_time,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity by Subject',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_progress.isEmpty)
                Text(
                  'Progress will appear after you complete chat or quiz sessions.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ..._progress.entries.map(
                  (entry) => _BarRow(
                    label: entry.key,
                    value: (entry.value as num).toDouble() / 100,
                    color: colors.primary,
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
                'AI Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _recommendation['recommendations']?.toString() ??
                    'Keep moving with one study session and one quiz today.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _bootstrap,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Insights'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${(value * 100).toStringAsFixed(0)}%'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
