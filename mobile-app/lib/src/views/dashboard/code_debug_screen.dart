import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class CodeDebugScreen extends StatelessWidget {
  const CodeDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(
              icon: Icons.bug_report_outlined,
              text: 'Debug',
              selected: true,
            ),
            _Pill(icon: Icons.terminal, text: 'Explain'),
            _Pill(icon: Icons.auto_fix_high, text: 'Optimize'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _LangChip(label: 'Python', selected: true),
            _LangChip(label: 'JavaScript'),
            _LangChip(label: 'Java'),
            _LangChip(label: 'C++'),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code Input',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 190,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: const Text(
                  "def add(a, b):\n    return a + b\n\nprint(add(2, '3'))",
                  style: TextStyle(fontFamily: 'monospace', height: 1.5),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Analyze'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Run'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
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
                'AI Analysis',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Issue: mixed int and string types. Convert second arg to int before addition.\n\nImproved:\n\ndef add(a, b):\n    return a + int(b)\n\nprint(add(2, \"3\"))',
                style: TextStyle(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, this.selected = false});

  final IconData icon;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) {},
      avatar: Icon(icon, size: 16),
      label: Text(text),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
    );
  }
}
