import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecoverPasswordPhonePage extends StatefulWidget {
  const RecoverPasswordPhonePage({super.key});

  @override
  State<RecoverPasswordPhonePage> createState() =>
      _RecoverPasswordPhonePageState();
}

class _RecoverPasswordPhonePageState extends State<RecoverPasswordPhonePage> {
  final phoneCtrl = TextEditingController();
  final smsCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String? verificationId;
  bool codeSent = false;
  bool verified = false;

  // Enviar SMS al usuario
  Future<void> sendCode() async {
    print("🔥 Enviando código a ${phoneCtrl.text}");
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneCtrl.text.trim(),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("✅ verificationCompleted llamado");
          // Auto-signin (opcional)
          await FirebaseAuth.instance.signInWithCredential(credential);
          setState(() => verified = true);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ verificationFailed: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.message}")),
          );
        },
        codeSent: (String verId, int? resendToken) {
          print("🔥 CODE SENT");
          setState(() {
            verificationId = verId;
            codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          print("⌛ codeAutoRetrievalTimeout");
          verificationId = verId;
        },
      );
    } catch (e) {
      print("⚠ Exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Exception: $e")));
    }
  }

  // Verificar el código SMS
  Future<void> verifyCode() async {
    if (verificationId == null) return;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCtrl.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      print("✅ Teléfono verificado con código");

      setState(() => verified = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teléfono verificado")),
      );
    } catch (e) {
      print("❌ Código incorrecto: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código incorrecto")),
      );
    }
  }

  // Actualizar contraseña (con reautenticación)
  Future<void> updatePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Usuario no encontrado")));
        return;
      }

      // Reautenticación con el credential de teléfono
      if (verificationId != null && smsCtrl.text.isNotEmpty) {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: smsCtrl.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);
        print("🔑 Usuario reautenticado");
      }

      await user.updatePassword(passCtrl.text.trim());
      print("✅ Contraseña actualizada");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña actualizada")),
      );

      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } catch (e) {
      print("❌ Error al actualizar contraseña: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecoration(
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.blueGrey.shade900,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        title: const Text("Recuperar contraseña",
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TELÉFONO
            TextField(
              controller: phoneCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle.copyWith(labelText: "Número de teléfono"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            if (!codeSent)
              ElevatedButton(
                onPressed: sendCode,
                child: const Text("Enviar código"),
              ),

            if (codeSent && !verified) ...[
              const SizedBox(height: 20),

              // CÓDIGO SMS
              TextField(
                controller: smsCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: inputStyle.copyWith(labelText: "Código SMS"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: verifyCode,
                child: const Text("Verificar código"),
              ),
            ],

            if (verified) ...[
              const SizedBox(height: 30),

              // NUEVA CONTRASEÑA
              TextField(
                controller: passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: inputStyle.copyWith(labelText: "Nueva contraseña"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: updatePassword,
                child: const Text("Actualizar contraseña"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
