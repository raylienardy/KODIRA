enum PasswordStrength { weak, medium, strong }

class PasswordStrengthLogic {
  static final RegExp _strongRegex = RegExp(
    r'^(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[!@#$%^&*]).{10,}$',
  );
  static final RegExp _mediumRegex = RegExp(
    r'^(?=.*[0-9])(?=.*[a-zA-Z]).{8,}$',
  );

  static const int minLength = 6;

  static PasswordStrength evaluate(String password) {
    if (_strongRegex.hasMatch(password)) return PasswordStrength.strong;
    if (_mediumRegex.hasMatch(password)) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  static String label(PasswordStrength s) => switch (s) {
    PasswordStrength.weak => 'Lemah',
    PasswordStrength.medium => 'Sedang',
    PasswordStrength.strong => 'Kuat',
  };
}
