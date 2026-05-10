import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    child: _MetaBox(label: 'Subject', value: 'Data Structures'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetaBox(label: 'Difficulty', value: 'Beginner'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Create Quiz'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Active Quiz',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 4),
                  const Text('08:42'),
                ],
              ),
              const SizedBox(height: 10),
              const LinearProgressIndicator(value: 0.3, minHeight: 8),
              const SizedBox(height: 12),
              Text('Question 3 of 10', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                'What is the time complexity of binary search in a sorted array?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const _OptionCard(text: 'O(n)'),
              const SizedBox(height: 8),
              const _OptionCard(text: 'O(log n)', selected: true),
              const SizedBox(height: 8),
              const _OptionCard(text: 'O(n log n)'),
              const SizedBox(height: 8),
              const _OptionCard(text: 'O(1)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Previous'),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: () {}, child: const Text('Next')),
                ],
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
                'Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const _RecommendationItem(
                title: 'Priority: Arrays revision quiz',
                subtitle:
                    'Your last 2 attempts had low accuracy in indexing questions.',
              ),
              const SizedBox(height: 8),
              const _RecommendationItem(
                title: 'Try intermediate recursion set',
                subtitle:
                    'You have completed beginner recursion in 3 sessions.',
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
  const _OptionCard({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
