import 'package:flutter/material.dart';

class PasswordValidationView extends StatefulWidget {
  final TextEditingController passwordController;

  const PasswordValidationView({
    super.key,
    required this.passwordController,
  });

  @override
  State<PasswordValidationView> createState() => _PasswordValidationViewState();
}

class _PasswordValidationViewState extends State<PasswordValidationView> {
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
    _validatePassword(); // Initial validation
  }

  @override
  void didUpdateWidget(covariant PasswordValidationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passwordController != widget.passwordController) {
      oldWidget.passwordController.removeListener(_validatePassword);
      widget.passwordController.addListener(_validatePassword);
    }
    _validatePassword(); // Re-validate when controller updates
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_validatePassword);
    super.dispose();
  }

  void _validatePassword() {
    final pass = widget.passwordController.text;
    setState(() {
      _hasMinLength = pass.length >= 12;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(pass);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(pass);
      _hasNumber = RegExp(r'[0-9]').hasMatch(pass);
      _hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(pass);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Debe contener:',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildValidationRow('Mínimo 12 caracteres', _hasMinLength),
        _buildValidationRow('Al menos 1 mayúscula', _hasUppercase),
        _buildValidationRow('Al menos 1 minúscula', _hasLowercase),
        _buildValidationRow('Al menos 1 número', _hasNumber),
        _buildValidationRow('Al menos 1 símbolo', _hasSymbol),
      ],
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.remove_circle_outline,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
