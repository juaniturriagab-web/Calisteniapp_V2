import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUserData({
    required String uid,
    required String email,
    required String phone,
    required String level,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'phone': phone,
      'level': level,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
