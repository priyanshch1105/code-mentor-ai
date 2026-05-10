import 'package:flutter/material.dart';

import '../utils/theme_utils.dart';
import '../widgets/feature_card.dart';
import '../widgets/session_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = ThemeUtils.getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    'Welcome back, Priyansh',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your coding momentum is strong today.',
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
                            ? [const Color(0xFF4F46E5), const Color(0xFFC4B5FD)]
                            : [const Color(0xFF4F46E5), const Color(0xFFA5B4FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.2),
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
                        const Text(
                          'Complete 2 debugging sessions and 1 quiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '65% Complete - 1 of 3 tasks done',
                          style: TextStyle(
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
                  const SessionTile(
                    topic: 'Binary Search Edge Cases',
                    time: 'Today, 10:40 AM',
                    tag: 'Debug',
                  ),
                  const SessionTile(
                    topic: 'OOP in Java Quick Revision',
                    time: 'Today, 9:05 AM',
                    tag: 'Tutor',
                  ),
                  const SessionTile(
                    topic: 'DSA Quiz - Arrays',
                    time: 'Yesterday, 8:30 PM',
                    tag: 'Quiz',
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
