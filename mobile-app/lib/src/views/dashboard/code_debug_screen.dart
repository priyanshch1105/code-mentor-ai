import 'package:flutter/material.dart';

import '../../controllers/controllers.dart';
import '../widgets/section_card.dart';

class CodeDebugScreen extends StatefulWidget {
  const CodeDebugScreen({super.key});

  @override
  State<CodeDebugScreen> createState() => _CodeDebugScreenState();
}

class _CodeDebugScreenState extends State<CodeDebugScreen> {
  final TextEditingController _codeController = TextEditingController(
    text: "def add(a, b):\n    return a + b\n\nprint(add(2, '3'))",
  );
  String _mode = 'debug';
  String _language = 'python';
  bool _loading = false;
  String? _analysis;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_codeController.text.trim().isEmpty || _loading) return;

    setState(() => _loading = true);

    try {
      final result = await CodeDebugController.instance.analyzeCode(
        code: _codeController.text,
        language: _language,
        mode: _mode,
      );

      if (!mounted) return;
      setState(() => _analysis = result.response);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code debug failed: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

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
              selected: _mode == 'debug',
              onTap: () => setState(() => _mode = 'debug'),
            ),
            _Pill(
              icon: Icons.terminal,
              text: 'Explain',
              selected: _mode == 'explain',
              onTap: () => setState(() => _mode = 'explain'),
            ),
            _Pill(
              icon: Icons.auto_fix_high,
              text: 'Optimize',
              selected: _mode == 'optimize',
              onTap: () => setState(() => _mode = 'optimize'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LangChip(
              label: 'Python',
              selected: _language == 'python',
              onTap: () => setState(() => _language = 'python'),
            ),
            _LangChip(
              label: 'JavaScript',
              selected: _language == 'javascript',
              onTap: () => setState(() => _language = 'javascript'),
            ),
            _LangChip(
              label: 'Java',
              selected: _language == 'java',
              onTap: () => setState(() => _language = 'java'),
            ),
            _LangChip(
              label: 'C++',
              selected: _language == 'cpp',
              onTap: () => setState(() => _language = 'cpp'),
            ),
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
              TextField(
                controller: _codeController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Paste code here...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                ),
                style: const TextStyle(fontFamily: 'monospace', height: 1.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _loading ? null : _analyze,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
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
              Text(
                _analysis ??
                    'Run analysis to get debugging help, explanations, or optimizations from the backend.',
                style: const TextStyle(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 16),
      label: Text(text),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
