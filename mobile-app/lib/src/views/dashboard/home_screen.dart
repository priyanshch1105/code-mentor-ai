import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/response/session_summary.dart';
import '../utils/theme_utils.dart';
import '../widgets/feature_card.dart';
import '../widgets/session_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _username = 'Learner';
  String _subject = 'code tutor';
  Map<String, dynamic> _progress = {};
  String _recommendation = '';
  List<SessionSummary> _sessions = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final profile = await AuthController.instance.loadCurrentUser();
      final sessions = await ChatController.instance.getSessions();
      final progress = await ChatController.instance.getProgress();
      final recommendation = await ChatController.instance.getRecommendation(
        subject: profile.currentSubject,
      );
      if (!mounted) return;
      setState(() {
        _username = profile.username;
        _subject = profile.currentSubject;
        _sessions = sessions;
        _progress = Map<String, dynamic>.from(
          progress['progress'] is Map ? progress['progress'] as Map : {},
        );
        _recommendation = recommendation;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _recommendation = 'Unable to load dashboard data: ${error.toString()}';
      });
    }
  }

  double _overallProgress() {
    if (_progress.isEmpty) return 0;
    final values = _progress.values
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a + b) / values.length / 100).clamp(0, 1);
  }

  String _formatTime(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';
    final local = createdAt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.month}/${local.day}, $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = ThemeUtils.getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $_username',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your current focus is ${_subject == 'general' ? 'CODE TUTOR' : _subject.toUpperCase()}.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF4F46E5), const Color(0xFF93C5FD)]
                            : [
                                const Color(0xFF0F766E),
                                const Color(0xFF22C55E),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Goal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete one ${_subject == 'general' ? 'code tutor' : _subject} session and one quiz',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: _overallProgress().clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_overallProgress() * 100).toStringAsFixed(0)}% average progress across subjects',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Explore',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _recommendation.isEmpty
                        ? 'Your mentor will surface the next best action here.'
                        : _recommendation,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                FeatureCard(
                  icon: Icons.smart_toy_outlined,
                  title: 'AI Tutor',
                  subtitle: 'Ask concepts in real time',
                  color: colors.primary,
                ),
                FeatureCard(
                  icon: Icons.code_off_outlined,
                  title: 'Code Debug',
                  subtitle: 'Find and fix bugs quickly',
                  color: colors.warning,
                ),
                FeatureCard(
                  icon: Icons.quiz_outlined,
                  title: 'Adaptive Quiz',
                  subtitle: 'Practice by skill level',
                  color: colors.success,
                ),
                FeatureCard(
                  icon: Icons.auto_graph_outlined,
                  title: 'Smart Insights',
                  subtitle: 'Track strengths weekly',
                  color: colors.secondary,
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Sessions',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_sessions.isEmpty)
                    Text(
                      'No sessions yet. Start a chat to see your history here.',
                      style: textTheme.bodyMedium,
                    )
                  else
                    ..._sessions
                        .take(3)
                        .map(
                          (session) => SessionTile(
                            topic: session.name,
                            time: _formatTime(session.createdAt),
                            tag: session.subject,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
