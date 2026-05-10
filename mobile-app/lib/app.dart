import 'package:flutter/material.dart';

import 'screens/chat_screen.dart';
import 'screens/code_debug_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quiz_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell_header.dart';

class CodeMentorApp extends StatefulWidget {
  const CodeMentorApp({super.key});

  @override
  State<CodeMentorApp> createState() => _CodeMentorAppState();
}

class _CodeMentorAppState extends State<CodeMentorApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code Mentor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainShell(
        isDark: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.isDark, required this.onThemeToggle});

  final bool isDark;
  final VoidCallback onThemeToggle;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ChatScreen(),
      const CodeDebugScreen(),
      const QuizScreen(),
      const DashboardScreen(),
      ProfileScreen(isDark: widget.isDark, onThemeToggle: widget.onThemeToggle),
    ];

    const titles = ['Code Mentor', 'Code Debugger', 'Quiz System', 'Progress Dashboard', 'Profile'];
    const subtitles = [
      'Chat, search, and subject workflows',
      'Debug, explain, optimize code',
      'Adaptive quiz and recommendations',
      'Sessions, accuracy, and insights',
      'Account and appearance settings',
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppShellHeader(
              title: titles[_selectedIndex],
              subtitle: subtitles[_selectedIndex],
              isDark: widget.isDark,
              onThemeToggle: widget.onThemeToggle,
            ),
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.code_outlined), selectedIcon: Icon(Icons.code), label: 'Debug'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
