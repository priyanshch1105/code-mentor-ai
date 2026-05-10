import 'package:flutter/material.dart';
import 'views/utils/app_theme.dart';
import 'views/dashboard/bottomnavscreen.dart';

void main() {
  runApp(const CodeMentorApp());
}

class CodeMentorApp extends StatefulWidget {
  const CodeMentorApp({super.key});

  @override
  State<CodeMentorApp> createState() => _CodeMentorAppState();
}

class _CodeMentorAppState extends State<CodeMentorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeTutor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _AppShellWithThemeToggle(onToggleTheme: _toggleTheme),
    );
  }
}

class _AppShellWithThemeToggle extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const _AppShellWithThemeToggle({required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return AppShell(onToggleTheme: onToggleTheme);
  }
}