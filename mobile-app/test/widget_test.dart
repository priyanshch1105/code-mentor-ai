import 'package:flutter_test/flutter_test.dart';
import 'package:code_mentor_mobile/app.dart';

void main() {
  testWidgets('App shell renders', (tester) async {
    await tester.pumpWidget(const CodeMentorApp());
    expect(find.text('Home'), findsOneWidget);
  });
}
