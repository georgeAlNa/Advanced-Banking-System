import 'input_validation_type.dart';

class InputValidator {
  static String? validate({
    required String value,
    required InputValidationType type,
    String? customPattern,
  }) {
    if (value.trim().isEmpty) {
      return "Can't Be Empty";
    }

    String pattern = '';

    switch (type) {
      case InputValidationType.email:
        pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
        break;

      case InputValidationType.phone:
        pattern = r'^\+963\d{9}$';
        break;

      case InputValidationType.emailOrPhone:
        pattern = r'^([\w-\.]+@([\w-]+\.)+[\w-]{2,4}|\+963\d{9})$';
        break;

      case InputValidationType.username:
        pattern = r'^[a-zA-Z0-9_]{3,16}$';
        break;

      case InputValidationType.password:
        pattern =
            r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[#$@!%&*()])[A-Za-z\d#$@!%&*()]{8,}$';
        break;

      case InputValidationType.number:
        pattern = r'^[0-9]+$';
        break;

      case InputValidationType.none:
        return null;
    }

    if (customPattern != null) {
      pattern = customPattern;
    }

    final regex = RegExp(pattern);
    if (!regex.hasMatch(value.trim())) {
      return _getErrorMessage(type, value);
    }

    return null;
  }

  static String _getErrorMessage(InputValidationType type, String value) {
    switch (type) {
      case InputValidationType.email:
        return "should be like: example@domain.com";

      case InputValidationType.phone:
        return "should be +963978...";

      case InputValidationType.emailOrPhone:
        return "Enter a valid email or Syrian phone (+963...)";

      case InputValidationType.username:
        return "Username should be 3-16 characters (letters, numbers, underscore only)";

      case InputValidationType.password:
        return "at least 8 char like :(a#\$@!%&*()211A...)";

      case InputValidationType.number:
        return "Only numbers are allowed";

      case InputValidationType.none:
        return "Invalid format";

      // ignore: unreachable_switch_default
      default:
        return "Invalid format";
    }
  }
}
