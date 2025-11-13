import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/level_selector.dart';
import '../widgets/calisthenics_logo.dart';
import '../utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? level;
  bool _loading = false;

  final primary = const Color(0xFF0A4CFF); // color principal azul

  Future<void> register() async {
    final emailError = Validators.validateEmail(emailCtrl.text);
    if (emailError != null) return showError(emailError);

    final phoneError = Validators.validatePhone(phoneCtrl.text);
    if (phoneError != null) return showError(phoneError);

    final passError = Validators.validatePassword(passCtrl.text);
    if (passError != null) return showError(passError);

    if (level == null) return showError('Selecciona tu nivel');

    setState(() => _loading = true);

    try {
      // 1️⃣ Crear usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailCtrl.text.trim(),
              password: passCtrl.text.trim());

      final user = userCredential.user;

      if (user != null) {
        // 2️⃣ Enviar correo de verificación
        await user.sendEmailVerification();

        // 3️⃣ Guardar datos en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'level': level,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showSuccess('Cuenta creada. Verifica tu correo.');

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Error desconocido');
    } finally {
      setState(() => _loading = false);
    }
  }

  void showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void showSuccess(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44), // fondo oscuro
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const CalisthenicsLogo(),
            const SizedBox(height: 20),
            Text(
              'Crear Cuenta',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primary, // uso de primary
              ),
            ),
            const SizedBox(height: 30),
            _input('Correo', emailCtrl, Icons.email_outlined),
            const SizedBox(height: 15),
            _input('Número de teléfono', phoneCtrl, Icons.phone_android,
                type: TextInputType.phone),
            const SizedBox(height: 15),
            _input('Contraseña', passCtrl, Icons.lock_outline, obscure: true),
            const SizedBox(height: 20),
            LevelSelector(onSelected: (v) => level = v),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary, // uso de primary
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrarse', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: primary), // uso de primary
        filled: true,
        fillColor: Colors.blueGrey.shade900,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
