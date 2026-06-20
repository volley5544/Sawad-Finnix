import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sawad_finnix/core/state/app_state.dart';
import 'package:sawad_finnix/main.dart';

void main() {
  testWidgets('App boots through splash to the phone onboarding screen',
      (WidgetTester tester) async {
    // No local PIN stored → the splash gate should route a fresh user to the
    // phone onboarding step. Mock secure storage so it is usable in tests.
    FlutterSecureStorage.setMockInitialValues({});

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
