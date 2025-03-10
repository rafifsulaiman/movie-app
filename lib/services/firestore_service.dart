import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Simpan data user ke Firestore setelah register
  Future<void> saveUserData(String uid, String fullname, String nickname, String hobby, String instagram) async {
    await _db.collection("users").doc(uid).set({
      "fullname": fullname,
      "nickname": nickname,
      "hobby": hobby,
      "instagram": instagram,
    });
  }

  // 🔥 Ambil data user dari Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    DocumentSnapshot doc = await _db.collection("users").doc(uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }
}
