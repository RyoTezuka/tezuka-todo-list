import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTodoDataProvider {
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
        .orderBy('title')
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTodoDetail({
    required String uid,
    required String id,
  }) async {
    return await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(uid)
        .collection('todo_collection')
        .doc(id)
        .get();
  }

  Future<String> createTodoDetail({
    required String uid,
    required String title,
    required DateTime deadline,
    required String priority,
    required String detail,
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
      'title': title,
      'deadline': Timestamp.fromDate(deadline),
      'priority': priority,
      'detail': detail,
      'create_timestamp': FieldValue.serverTimestamp(),
    });
    return 'success';
  }

  Future<String> updateTodoDetail({
    required String uid,
    required String id,
    required String title,
    required DateTime deadline,
    required String priority,
    required String detail,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(uid)
        .collection(
          'todo_collection',
        )
        .doc(id)
        .update({
      'title': title,
      'deadline': Timestamp.fromDate(deadline),
      'priority': priority,
      // 'detail': '今日からクリスマスまではスイーツ禁止。\n\nさらに甘いものを食べた人は一回につき罰金1000円を慈善団体に寄付しなければならない。',
      'detail': detail,
      'update_timestamp': FieldValue.serverTimestamp(),
    });
    return 'success';
  }

  Future<String> deleteTodoDetail({
    required String uid,
    required String id,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(uid)
        .collection(
          'todo_collection',
        )
        .doc(id)
        .delete();
    return 'success';
  }
}
