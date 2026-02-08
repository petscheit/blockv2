import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blockv2/app.dart';

void main() {
  testWidgets('shows setup screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const BlockApp());
    await tester.pumpAndSettle();

    expect(find.text('The Block'), findsOneWidget);
    expect(find.text('Start Passive Session'), findsOneWidget);
  });
}
