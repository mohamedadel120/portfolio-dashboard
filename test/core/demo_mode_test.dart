import 'package:flutter_test/flutter_test.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';

void main() {
  test('demo mode is off unless built with --dart-define=DEMO=true', () {
    // CI and release builds never pass DEMO, so production keeps the auth
    // gate and the real Firestore data sources.
    expect(demoMode, isFalse);
  });
}
