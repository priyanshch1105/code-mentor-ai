import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
    required this.onLogout,
  });

  final bool isDark;
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String _username = 'Learner';
  String _email = '';
  String _subject = 'general';
  Map<String, dynamic> _progress = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final profile = await AuthController.instance.loadCurrentUser();
      final progress = await ChatController.instance.getProgress();
      if (!mounted) return;
      setState(() {
        _username = profile.username;
        _email = profile.email;
        _subject = profile.currentSubject;
        _progress = Map<String, dynamic>.from(progress['progress'] is Map ? progress['progress'] as Map : {});
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
      await _bootstrap();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject update failed: ${error.toString()}')),
      );
    }
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(_email.isEmpty ? '@user' : _email, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _bootstrap,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoTile(
                icon: Icons.school_outlined,
                label: 'Preferred Subject',
                value: _subject.toUpperCase(),
              ),
              _InfoTile(
                icon: Icons.analytics_outlined,
                label: 'Tracked Subjects',
                value: _progress.isEmpty ? 'No progress yet' : _progress.keys.join(', '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current mode: ${widget.isDark ? 'Dark' : 'Light'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: widget.onThemeToggle,
                icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
                label: const Text('Toggle Theme'),
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
                'Switch Subject',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(label: const Text('Coding'), selected: _subject == 'coding', onSelected: (_) => _setSubject('coding')),
                  ChoiceChip(label: const Text('Math'), selected: _subject == 'math', onSelected: (_) => _setSubject('math')),
                  ChoiceChip(label: const Text('Physics'), selected: _subject == 'physics', onSelected: (_) => _setSubject('physics')),
                  ChoiceChip(label: const Text('IELTS'), selected: _subject == 'ielts', onSelected: (_) => _setSubject('ielts')),
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
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _bootstrap,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Refresh Data'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
