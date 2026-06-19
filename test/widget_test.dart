import 'package:flutter_test/flutter_test.dart';

import 'package:sawad_finnix/core/state/app_state.dart';
import 'package:sawad_finnix/main.dart';

void main() {
  testWidgets('App boots to the phone onboarding screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SawadFinnixApp());
    await tester.pumpAndSettle();

    // Phone page content from the onboarding flow.
    expect(find.text('ยินดีต้อนรับ'), findsOneWidget);
    expect(find.text('ขอรหัส OTP'), findsOneWidget);
  });

  test('AppState resolves an environment config', () {
    expect(AppState.instance.env.firebaseProjectId, isNotEmpty);
  });
}
