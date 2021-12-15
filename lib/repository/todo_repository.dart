import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/model/TodoModel.dart';

class TodoRepository {
  final FirebaseTodoDataProvider firebaseTodoDataProvider;
  final FirebaseAuthDataProvider firebaseAuthDataProvider;

  TodoRepository({
    required this.firebaseTodoDataProvider,
    required this.firebaseAuthDataProvider,
  });

  Future<String> createUserData({
    required String email,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.createUserDocument(
        uid: user!.uid,
        name: email,
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

  Future<List<TodoModel>> getTodoList() async {
    Intl.defaultLocale = "ja_JP";
    initializeDateFormatting("ja_JP");
    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm", "ja_JP");

    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      final res = await firebaseTodoDataProvider.getTodoList(
        uid: user!.uid,
      );
      List<TodoModel> list = [];
      for (var element in res.docs) {
        TodoModel todoModel = TodoModel(
          todoId: element.id,
          title: element['title'],
          deadline: dateFormat.format(element['deadline'].toDate()),
          priority: element['priority'],
          detail: element['detail'],
        );
        list.add(todoModel);
      }
      return list;
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

      return List.empty();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createTodoData({
    required TodoModel todoData,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.createTodoDetail(
        uid: user!.uid,
        title: todoData.title,
        deadline: todoData.deadline,
        detail: todoData.detail,
        priority: todoData.priority,
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
    required String todoId,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.deleteTodoDetail(
        uid: user!.uid,
        todoId: todoId,
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
    required TodoModel todoData,
  }) async {
    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      await firebaseTodoDataProvider.updateTodoDetail(
        uid: user!.uid,
        todoId: todoData.todoId,
        title: todoData.title,
        deadline: todoData.deadline,
        detail: todoData.detail,
        priority: todoData.priority,
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

  Future<TodoModel> getTodoData({
    required String todoId,
  }) async {
    Intl.defaultLocale = "ja_JP";
    initializeDateFormatting("ja_JP");
    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm", "ja_JP");

    try {
      User? user = await firebaseAuthDataProvider.getCurrentUser();
      final res = await firebaseTodoDataProvider.getTodoDetail(
        uid: user!.uid,
        todoId: todoId,
      );
      final resTodo = res.data()!;
      TodoModel todoModel = TodoModel(
        todoId: todoId,
        title: resTodo['title'],
        deadline: dateFormat.format(resTodo['deadline'].toDate()),
        priority: resTodo['priority'],
        detail: resTodo['detail'],
      );

      return todoModel;
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

      return [] as TodoModel;
    } catch (e) {
      rethrow;
    }
  }
}
