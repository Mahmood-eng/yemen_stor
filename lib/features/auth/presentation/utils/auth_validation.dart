class ValidationError {
  final String field;
  final String message;

  ValidationError(this.field, this.message);
}

class AuthValidation {
  static List<ValidationError> validateEmail(String email) {
    final errors = <ValidationError>[];
    if (email.isEmpty) {
      errors.add(ValidationError('email', 'البريد الإلكتروني مطلوب'));
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors.add(ValidationError('email', 'البريد الإلكتروني غير صحيح'));
    }
    return errors;
  }

  static List<ValidationError> validatePassword(String password) {
    final errors = <ValidationError>[];
    if (password.isEmpty) {
      errors.add(ValidationError('password', 'كلمة المرور مطلوبة'));
    } else if (password.length < 6) {
      errors.add(
        ValidationError('password', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
      );
    }
    return errors;
  }

  static List<ValidationError> validateDisplayName(String displayName) {
    final errors = <ValidationError>[];
    if (displayName.isEmpty) {
      errors.add(ValidationError('displayName', 'الاسم مطلوب'));
    } else if (displayName.length < 2) {
      errors.add(
        ValidationError('displayName', 'الاسم يجب أن يكون حرفين على الأقل'),
      );
    }
    return errors;
  }

  static List<ValidationError> validateCity(String? city) {
    final errors = <ValidationError>[];
    if (city == null || city.isEmpty) {
      errors.add(ValidationError('city', 'يجب اختيار المدينة'));
    }
    return errors;
  }

  static List<ValidationError> validateSignIn(String email, String password) {
    return [...validateEmail(email), ...validatePassword(password)];
  }

  static List<ValidationError> validateSignUp(
    String email,
    String password,
    String displayName,
    String? city,
  ) {
    return [
      ...validateEmail(email),
      ...validatePassword(password),
      ...validateDisplayName(displayName),
      ...validateCity(city),
    ];
  }
}
