import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';

class TodoRepository {
  late final FirebaseTodoDataProvider firebaseTodoDataProvider;
  late final FirebaseAuthDataProvider firebaseAuthDataProvider;

  TodoRepository({
    required this.firebaseTodoDataProvider,
    required this.firebaseAuthDataProvider,
  });

  // Future<Map<int, QueryDocumentSnapshot>?> getTodoData() async {
  // Future<List<Map<String, dynamic>>?> getTodoData() async {
  Future<Map<dynamic, dynamic>?> getTodoData() async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      return await firebaseTodoDataProvider.getTodoList(
        user: user!,
      );
      // return "success";
    } on FirebaseException catch (e) {
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

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createTodoData() async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.createTodoListDocument(
        user: user!,
      );
      return "success";
    } on FirebaseException catch (e) {
      // TODO データ作成失敗時の処理を実装する
      final code = () {
        switch (e.code) {
          case "success":
            return "OK";
          default:
            return "default";
        }
      }();
      return code;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createUserData({
    required String email,
    required String password,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.createUserDocument(
        user: user!,
        name: email,
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
