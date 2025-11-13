class Validators {
  static String? validateEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(email)) return 'Correo inválido';
    return null;
  }

  static String? validatePassword(String pass) {
    if (pass.length < 12) return 'Mínimo 12 caracteres';
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pass);
    final hasLower = RegExp(r'[a-z]').hasMatch(pass);
    final hasNumber = RegExp(r'[0-9]').hasMatch(pass);
    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(pass);

    if (!hasUpper || !hasLower || !hasNumber || !hasSymbol) {
      return 'Incluye mayúsculas, minúsculas, números y símbolos';
    }

    return null;
  }

  static String? validatePhone(String phone) {
    final txt = phone.trim();
    if (!txt.startsWith('+')) return 'Incluye código de país. Ej: +52XXXXXXXXXX';
    final digits = txt.substring(1);
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return 'Solo números después de +';
    if (digits.length < 10 || digits.length > 15) return 'Número inválido';
    return null;
  }
}
