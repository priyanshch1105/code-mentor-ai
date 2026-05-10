import 'package:flutter/material.dart';
import 'controllers/controllers.dart';
import 'views/onboarding/login_screen.dart';
import 'views/onboarding/signup_screen.dart';
import 'views/onboarding/splash_screen.dart';
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
  bool _isAuthenticated = false;
  bool _showSplash = true;
  bool _showSignup = false;

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

  Future<void> _handleSplashComplete() async {
    final hasToken = await AuthController.instance.hasToken();
    if (!mounted) return;
    setState(() {
      _isAuthenticated = hasToken;
      _showSplash = false;
      _showSignup = false;
    });
  }

  void _handleLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
      _showSignup = false;
    });
  }

  void _handleLogout() async {
    await AuthController.instance.logout();
    if (!mounted) return;
    setState(() {
      _isAuthenticated = false;
      _showSignup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeTutor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _showSplash
          ? SplashScreen(onComplete: _handleSplashComplete)
          : _isAuthenticated
              ? _AppShellWithThemeToggle(
                  onToggleTheme: _toggleTheme,
                  onLogout: _handleLogout,
                )
              : _showSignup
                  ? SignupScreen(
                      onSignupSuccess: _handleLoginSuccess,
                      onNavigateToLogin: () => setState(() => _showSignup = false),
                    )
                  : LoginScreen(
                      onLoginSuccess: _handleLoginSuccess,
                      onNavigateToSignup: () => setState(() => _showSignup = true),
                    ),
    );
  }
}

class _AppShellWithThemeToggle extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const _AppShellWithThemeToggle({
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppShell(
      onToggleTheme: onToggleTheme,
      onLogout: onLogout,
    );
  }
}