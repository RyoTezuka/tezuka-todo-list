import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_management/util/date_format_util.dart';

class FirebaseTodoDataProvider {
  Future<String> createUserDocument({
    required String uid,
    required String name,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(uid)
        .set({
      'name': name,
      'create_timestamp': FieldValue.serverTimestamp(),
    });
    return 'success';
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTodoList({
    required String uid,
  }) async {
    return await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .orderBy('deadline')
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTodoDetail({
    required String uid,
    required String todoId,
  }) async {
    return await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .doc(todoId)
        .get();
  }

  Future<String> createTodoDetail({
    required String uid,
    required String title,
    required String deadline,
    required String priority,
    required String detail,
  }) async {
    await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .doc()
        .set({
      'title': title,
      'deadline': formatStringToTimestamp(sDateTime: deadline),
      'priority': priority,
      'detail': detail,
      'create_timestamp': FieldValue.serverTimestamp(),
    });
    return 'success';
  }

  Future<String> updateTodoDetail({
    required String uid,
    required String todoId,
    required String title,
    required String deadline,
    required String priority,
    required String detail,
  }) async {
    await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .doc(todoId)
        .update({
      'title': title,
      'deadline': formatStringToTimestamp(sDateTime: deadline),
      'priority': priority,
      'detail': detail,
      'update_timestamp': FieldValue.serverTimestamp(),
    });
    return 'success';
  }

  Future<String> deleteTodoDetail({
    required String uid,
    required String todoId,
  }) async {
    await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .doc(todoId)
        .delete();
    return 'success';
  }
}
