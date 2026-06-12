import 'package:flutter_test/flutter_test.dart';
import 'package:task_reminder_mobile_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    expect(find.text('Student Management App'), findsOneWidget);
  });
}