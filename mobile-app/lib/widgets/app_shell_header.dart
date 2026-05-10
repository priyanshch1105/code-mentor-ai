import 'package:flutter/material.dart';

class AppShellHeader extends StatelessWidget {
  const AppShellHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onThemeToggle,
  });

  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onThemeToggle,
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
              ),
              const SizedBox(width: 6),
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
