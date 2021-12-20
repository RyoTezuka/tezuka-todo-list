import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/model/TodoModel.dart';
import 'package:todo_management/util/date_format_util.dart';

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
    User? user = await firebaseAuthDataProvider.getCurrentUser();
    await firebaseTodoDataProvider.createUserDocument(
      uid: user!.uid,
      name: email,
    );
    return "success";
  }

  Future<List<TodoModel>> getTodoList() async {
    User? user = await firebaseAuthDataProvider.getCurrentUser();
    final res = await firebaseTodoDataProvider.getTodoList(
      uid: user!.uid,
    );
    List<TodoModel> list = [];
    for (var element in res.docs) {
      TodoModel todoModel = TodoModel(
        todoId: element.id,
        title: element['title'],
        deadline: formatTimestampToString(tDateTime: element['deadline']),
        priority: element['priority'],
        detail: element['detail'],
      );
      list.add(todoModel);
    }
    return list;
  }

  Future<String> createTodoData({
    required TodoModel todoData,
  }) async {
    User? user = await firebaseAuthDataProvider.getCurrentUser();
    await firebaseTodoDataProvider.createTodoDetail(
      uid: user!.uid,
      title: todoData.title,
      deadline: todoData.deadline,
      detail: todoData.detail,
      priority: todoData.priority,
    );
    return "success";
  }

  Future<String> deleteTodoData({
    required String todoId,
  }) async {
    User? user = await firebaseAuthDataProvider.getCurrentUser();
    await firebaseTodoDataProvider.deleteTodoDetail(
      uid: user!.uid,
      todoId: todoId,
    );
    return "success";
  }

  Future<String> updateTodoData({
    required TodoModel todoData,
  }) async {
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
  }

  Future<TodoModel> getTodoData({
    required String todoId,
  }) async {
    User? user = await firebaseAuthDataProvider.getCurrentUser();
    final res = await firebaseTodoDataProvider.getTodoDetail(
      uid: user!.uid,
      todoId: todoId,
    );
    final resTodo = res.data()!;
    TodoModel todoModel = TodoModel(
      todoId: todoId,
      title: resTodo['title'],
      deadline: formatTimestampToString(tDateTime: resTodo['deadline']),
      priority: resTodo['priority'],
      detail: resTodo['detail'],
    );

    return todoModel;
  }
}
