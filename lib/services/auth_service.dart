import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Register User
  Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullname,
    required String nickname,
    required String hobby,
    required String instagram,
  }) async {
    try {
      print("Starting registration process...");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      print("FirebaseAuth success: User ID = ${user?.uid}");

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullname': fullname,
          'nickname': nickname,
          'hobby': hobby,
          'instagram': instagram,
          'email': email,
          'profile_picture': "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png", // ✅ Default image
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("Firestore success: Data saved for User ID = ${user.uid}");
        return user;
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.message}");
      rethrow;
    } on FirebaseException catch (e) {
      print("Firestore Error: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected Error: $e");
      rethrow;
    }

    return null;
  }

  // 🔹 Login User
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // 🔹 Logout User
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> addToWatchlist(int movieId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'watchlist': FieldValue.arrayUnion([movieId])
    });
  }

  Future<void> removeFromWatchlist(int movieId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'watchlist': FieldValue.arrayRemove([movieId])
    });
  }

  // Tambah film ke favorites
  Future<void> addToFavorites(int movieId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'favorites': FieldValue.arrayUnion([movieId])
      });
      print("✅ Movie $movieId added to favorites!");
    } catch (e) {
      print("🔥 Firestore Error (addToFavorites): $e");
    }
  }

  // Hapus film dari favorites
  Future<void> removeFromFavorites(int movieId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'favorites': FieldValue.arrayRemove([movieId])
      });
      print("✅ Movie $movieId removed from favorites!");
    } catch (e) {
      print("🔥 Firestore Error (removeFromFavorites): $e");
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("❌ No user logged in");
        return null;
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print("❌ User document not found");
        return null;
      }

      print("✅ User Data: ${userDoc.data()}"); // Debugging output

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print("🔥 Firestore Error: $e");
      return null;
    }
  }

    Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("❌ No user logged in");
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update(updatedData);
      print("✅ User data updated successfully!");
    } catch (e) {
      print("🔥 Firestore Error (updateUserData): $e");
    }
  }


  // 🔹 Cek Status Login
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
