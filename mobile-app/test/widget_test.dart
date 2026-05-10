import 'package:flutter_test/flutter_test.dart';
import 'package:code_mentor_mobile/src/main.dart';

void main() {
  testWidgets('App shell renders', (tester) async {
    await tester.pumpWidget(const CodeMentorApp());
    expect(find.text('CodeTutor'), findsOneWidget);
  });
}
