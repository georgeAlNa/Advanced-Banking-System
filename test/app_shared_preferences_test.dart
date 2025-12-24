import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advanced_banking_system/core/helpers/app_shared_preferences.dart';

void main() {
  group('AppSharedPreferences', () {
    setUp(() {
      // Ensure a clean, in-memory SharedPreferences instance for each test
      SharedPreferences.setMockInitialValues({});
    });

    test('is a singleton', () {
      final a = AppSharedPreferences();
      final b = AppSharedPreferences();
      expect(identical(a, b), isTrue);
    });

    test('set and get primitives', () async {
      final prefs = AppSharedPreferences();
      await prefs.init();

      await prefs.setString('stringKey', 'hello');
      expect(prefs.getString('stringKey'), 'hello');

      await prefs.setBool('boolKey', true);
      expect(prefs.getBool('boolKey'), isTrue);

      await prefs.setInt('intKey', 42);
      expect(prefs.getInt('intKey'), 42);

      await prefs.setDouble('doubleKey', 3.14);
      expect(prefs.getDouble('doubleKey'), closeTo(3.14, 1e-9));
    });

    test('removeKey and clear', () async {
      final prefs = AppSharedPreferences();
      await prefs.init();

      await prefs.setString('a', '1');
      await prefs.setString('b', '2');

      expect(prefs.getString('a'), '1');
      expect(prefs.getString('b'), '2');

      await prefs.removeKey('a');
      expect(prefs.getString('a'), isNull);
      expect(prefs.getString('b'), '2');

      final cleared = await prefs.clear();
      expect(cleared, isTrue);
      expect(prefs.getString('b'), isNull);
    });
  });
}
