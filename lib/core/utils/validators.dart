import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : AppStrings.fieldRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final req = required(value, 'Email');
    if (req != null) return req;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value!.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? phone(String? value) {
    final req = required(value, 'Phone');
    if (req != null) return req;
    final cleaned = value!.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (cleaned.length < 7 || cleaned.length > 15 || !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  static String? salary(String? value) {
    final req = required(value, 'Salary');
    if (req != null) return req;
    final amount = double.tryParse(value!.trim());
    if (amount == null || amount < 0) {
      return AppStrings.invalidSalary;
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? fieldName]) {
    final req = required(value, fieldName);
    if (req != null) return req;
    if (value!.trim().length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters';
    }
    return null;
  }

  static String? password(String? value) {
    final req = required(value, 'Password');
    if (req != null) return req;
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? employeeId(String? value) {
    final req = required(value, 'Employee ID');
    if (req != null) return req;
    if (value!.trim().length < 3) {
      return 'Employee ID must be at least 3 characters';
    }
    return null;
  }
}
