import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTodoDataProvider {
  Future<QuerySnapshot<Map<String, dynamic>>> getTodoList({
    required String uid,
  }) async {
    return await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .orderBy('title')
        .get();
  }

  Future<String> createTodoListDocument({
    required String uid,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(uid)
        .collection(
          'todo_collection',
        )
        .doc()
        .set({
      // TODO 画面で入力された値をセットできるように
      'title': 'クリスマスまでには',
      'deadline': '2021/12/25',
      'priority': 'SSS',
    });
    // final name = snapshot.docs.first.data()['name'];
    return 'success';
  }

  Future<String> createUserDocument({
    required String uid,
    required String name,
    required String password,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(uid)
        .set({
      'name': name,
      'password': password,
    });
    return 'success';
  }
}
