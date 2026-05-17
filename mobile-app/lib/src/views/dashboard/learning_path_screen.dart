import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../utils/theme_utils.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  bool _loading = true;
  String _subject = 'code tutor';
  Map<String, dynamic> _progress = {};
  String _recommendation = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final profile = await AuthController.instance.loadCurrentUser();
      final progressResponse = await ChatController.instance.getProgress();
      final recommendation = await ChatController.instance.getRecommendation(
        subject: profile.currentSubject,
      );
      if (!mounted) return;
      setState(() {
        _subject = profile.currentSubject;
        _progress = Map<String, dynamic>.from(
          progressResponse['progress'] is Map
              ? progressResponse['progress'] as Map
              : {},
        );
        _recommendation = recommendation;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _setSubject(String subject) async {
    try {
      await AuthController.instance.selectSubject(subject);
      final profile = await AuthController.instance.loadCurrentUser();
      final recommendation = await ChatController.instance.getRecommendation(
        subject: profile.currentSubject,
      );
      if (!mounted) return;
      setState(() {
        _subject = profile.currentSubject;
        _recommendation = recommendation;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject update failed: ${error.toString()}')),
      );
    }
  }

  List<_PathStepData> _stepsForSubject() {
    return const [
      _PathStepData('Arrays and two pointers', 0.9, 'Warm up complete'),
      _PathStepData('Binary search patterns', 0.6, '2 sessions left'),
      _PathStepData('Recursion and DP basics', 0.25, 'Start next'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ThemeUtils.getColors(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Path',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your personalized roadmap for this week',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Code Tutor'),
                        selected:
                            _subject == 'coding' || _subject == 'code tutor',
                        onSelected: (_) => _setSubject('coding'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: colors.primary.withValues(alpha: 0.08),
                    ),
                    child: Text(
                      _recommendation.isEmpty
                          ? 'Your next best step will appear here.'
                          : _recommendation,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_progress.length} subjects are tracked in your profile',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._stepsForSubject().asMap().entries.expand((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return [
                    _PathStep(
                      title: step.title,
                      progress: step.progress,
                      eta: step.eta,
                      color: index.isEven ? colors.primary : colors.success,
                      index: index + 1,
                    ),
                    const SizedBox(height: 12),
                  ];
                }),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathStepData {
  const _PathStepData(this.title, this.progress, this.eta);

  final String title;
  final double progress;
  final String eta;
}

class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.title,
    required this.progress,
    required this.eta,
    required this.color,
    required this.index,
  });

  final String title;
  final double progress;
  final String eta;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.surfaceContainerHighest,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eta,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}% Complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
