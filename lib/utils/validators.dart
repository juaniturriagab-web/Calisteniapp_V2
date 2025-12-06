class Validators {
  static String? validateEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(email)) return 'Correo inválido';
    return null;
  }

  static String? validatePassword(String pass) {
    if (pass.length < 12) {
    return  'Contraseña poco segura';
    }
    return null;
  }

  static String? validatePhone(String phone) {
    final txt = phone.trim();
    if (!txt.startsWith('+')) return 'Incluye código de país. Ej: +56XXXXXXXXX';
    final digits = txt.substring(1);
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return 'Solo números después de +, elimine espacios u otros caracteres';
    if (digits.length < 10 || digits.length > 15) return 'Número inválido';
    return null;
  }
}
