// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ieee_mobile_app/main.dart';

void main() {
  testWidgets('IEEE App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IEEEApp());
    
    // Wait for initial frame
    await tester.pump();
    
    // Wait for async operations to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify that the welcome text is displayed.
    expect(find.text('Welcome Home'), findsOneWidget);
    expect(find.text('See Upcoming Events'), findsOneWidget);
  });
}
