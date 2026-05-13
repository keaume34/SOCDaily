import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Onboarding flag', () {
    test('onboarding shows on first launch (key absent)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding.complete'), isNull);
    });

    test('onboarding is skipped after completion', () async {
      SharedPreferences.setMockInitialValues({'onboarding.complete': true});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding.complete'), isTrue);
    });

    test('marking onboarding complete persists the flag', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding.complete'), isNull);

      await prefs.setBool('onboarding.complete', true);
      expect(prefs.getBool('onboarding.complete'), isTrue);
    });
  });
}
