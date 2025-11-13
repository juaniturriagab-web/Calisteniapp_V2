import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  const PasswordStrengthMeter({super.key, required this.password});

  double get strength {
    if (password.isEmpty) return 0;
    double score = 0;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) score += 0.25;
    return score;
  }

  Color get color {
    if (strength < 0.5) return Colors.red;
    if (strength < 0.75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: strength,
      backgroundColor: Colors.grey.shade300,
      color: color,
      minHeight: 6,
    );
  }
}
