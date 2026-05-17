import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:code_mentor_mobile/src/views/onboarding/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders and completes', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onComplete: () {
            completed = true;
          },
        ),
      ),
    );

    expect(find.text('Code Mentor AI'), findsOneWidget);
    expect(find.text('Your AI Coding Companion'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(completed, isTrue);
  });
}
