class PasswordStrength {
  static int calculate(String pass) {
    int score = 0;

    if (pass.length >= 12) score += 30;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score += 20;
    if (RegExp(r'[a-z]').hasMatch(pass)) score += 20;
    if (RegExp(r'[0-9]').hasMatch(pass)) score += 15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(pass)) score += 15;

    return score.clamp(0, 100);
  }

  static String label(int value) {
    if (value < 40) return 'Débil';
    if (value < 70) return 'Media';
    return 'Fuerte';
  }
}
