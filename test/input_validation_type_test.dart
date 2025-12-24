import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_banking_system/core/helpers/input_validation_type.dart';

void main() {
  group('InputValidationType enum', () {
    test('contains expected values in order', () {
      expect(InputValidationType.values, equals([
        InputValidationType.none,
        InputValidationType.email,
        InputValidationType.phone,
        InputValidationType.username,
        InputValidationType.password,
        InputValidationType.number,
        InputValidationType.emailOrPhone,
      ]));
    });

    test('has correct length', () {
      expect(InputValidationType.values.length, 7);
    });
  });
}
