import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataProvider {
  Future<User?> getCurrentUser() async {
    return await FirebaseAuth.instance.authStateChanges().first;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
