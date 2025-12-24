import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_banking_system/core/helpers/input_validator.dart';
import 'package:advanced_banking_system/core/helpers/input_validation_type.dart';

void main() {
  group('InputValidator', () {
    test('returns error when empty', () {
      expect(
        InputValidator.validate(value: '', type: InputValidationType.email),
        "Can't Be Empty",
      );
    });

    test('valid email returns null', () {
      expect(
        InputValidator.validate(value: 'test@example.com', type: InputValidationType.email),
        isNull,
      );
    });

    test('invalid email returns appropriate message', () {
      expect(
        InputValidator.validate(value: 'bademail', type: InputValidationType.email),
        'should be like: example@domain.com',
      );
    });

    test('valid phone returns null', () {
      expect(
        InputValidator.validate(value: '+963978000000', type: InputValidationType.phone),
        isNull,
      );
    });

    test('custom pattern overrides default', () {
      // custom pattern allows lowercase letters only
      expect(
        InputValidator.validate(value: 'abc', type: InputValidationType.email, customPattern: r'^[a-z]+$'),
        isNull,
      );
    });
  });
}