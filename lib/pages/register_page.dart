import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/level_selector.dart';
import '../widgets/calisthenics_logo.dart';
import '../utils/validators.dart';
import '../widgets/password_validation_view.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? level;
  bool _loading = false;

  final primary = const Color(0xFF0A4CFF);

  @override
  void dispose() {
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> register() async {
    // Validaciones básicas
    if (usernameCtrl.text.trim().isEmpty) {
      return showError("Ingresa un nombre de usuario");
    }

    final emailError = Validators.validateEmail(emailCtrl.text);
    if (emailError != null) return showError(emailError);

    final phoneError = Validators.validatePhone(phoneCtrl.text);
    if (phoneError != null) return showError(phoneError);

    final passError = Validators.validatePassword(passCtrl.text);
    if (passError != null) return showError(passError);

    if (level == null) return showError('Selecciona tu nivel');

    setState(() => _loading = true);

    try {
      // 1️⃣ Verificar si el nombre de usuario ya existe
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameCtrl.text.trim())
          .get();

      if (query.docs.isNotEmpty) {
        setState(() => _loading = false);
        return showError("Ese nombre de usuario ya está en uso");
      }

      // 2️⃣ Crear usuario
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        // 3️⃣ Enviar correo de verificación
        await user.sendEmailVerification();

        // 4️⃣ Guardar datos en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': usernameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'level': level,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        showSuccess("Cuenta creada. Verifica tu correo.");
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
      backgroundColor: const Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 0),
            const CalisthenicsLogo(),
            const SizedBox(height: 20),
            Text(
              'Crear Cuenta',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Nombre de usuario
            _input("Nombre de usuario", usernameCtrl, Icons.person, focusNode: _usernameFocus),

            const SizedBox(height: 15),
            _input("Correo", emailCtrl, Icons.email_outlined, focusNode: _emailFocus),
            const SizedBox(height: 15),
            _input("Número de teléfono", phoneCtrl, Icons.phone_android,
                type: TextInputType.phone, focusNode: _phoneFocus),
            const SizedBox(height: 15),
            _input("Contraseña", passCtrl, Icons.lock_outline, obscure: true, focusNode: _passwordFocus),
            const SizedBox(height: 15),
            PasswordValidationView(passwordController: passCtrl),

            const SizedBox(height: 20),
            LevelSelector(onSelected: (v) => level = v),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
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
      {bool obscure = false, TextInputType type = TextInputType.text, FocusNode? focusNode}) {
    return GestureDetector(
      onTap: () {
        if (focusNode != null) {
          if(focusNode.hasFocus) {
            SystemChannels.textInput.invokeMethod('TextInput.show');
          } else {
            FocusScope.of(context).requestFocus(focusNode);
          }
        }
      },
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: const Color(0xFF0A1F44), // azul oscuro
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
