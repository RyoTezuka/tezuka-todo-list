import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';

class AuthRepository {
  late final FirebaseAuthDataProvider firebaseAuthDataProvider;

  AuthRepository({
    required this.firebaseAuthDataProvider,
  });

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuthDataProvider.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      final code = () {
        switch (e.code) {
          case "invalid-name":
            return "invalid_name";
          case "user_disabled":
            return "user_disabled";
          default:
            return "unexpected_error";
        }
      }();

      return code;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> registration({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuthDataProvider.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      String code = e.code;
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return code;
    } catch (e) {
      rethrow;
    }
  }
}
