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

  Future<String> createUserData({
    required String email,
    required String password,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.createUserDocument(
        uid: user!.uid,
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

  Future<Map<dynamic, dynamic>?> getTodoList() async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      final res = await firebaseTodoDataProvider.getTodoList(
        uid: user!.uid,
      );
      List<Map<dynamic, dynamic>> list = [];
      Map<dynamic, Map<dynamic, dynamic>> result = {};
      for (var element in res.docs) {
        Map<dynamic, dynamic> value = {};
        value['id'] = element.id;
        value['title'] = element['title'];
        value['deadline'] = element['deadline'];
        value['priority'] = element['priority'];
        list.add(value);
      }
      var i = 0;
      for (var value in list) {
        result[i++] = value;
      }
      return result;
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

      return {};
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createTodoData({
    required Map todoData,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.createTodoDetail(
        uid: user!.uid,
        title: todoData['title'],
        deadline: todoData['deadline'],
        detail: todoData['detail'],
        priority: todoData['priority'],
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

  Future<String> deleteTodoData({
    required String id,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.deleteTodoDetail(
        uid: user!.uid,
        id: id,
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

  Future<String> updateTodoData({
    required Map todoData,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.updateTodoDetail(
        uid: user!.uid,
        id: todoData['id'],
        title: todoData['title'],
        deadline: todoData['deadline'],
        detail: todoData['detail'],
        priority: todoData['priority'],
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

  Future<Map<dynamic, dynamic>?> getTodoData({
    required String id,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      final res = await firebaseTodoDataProvider.getTodoDetail(
        uid: user!.uid,
        id: id,
      );
      return res.data();
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

      return {};
    } catch (e) {
      rethrow;
    }
  }
}
