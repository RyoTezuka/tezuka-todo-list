import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTodoDataProvider {
  Future<Map<dynamic, dynamic>> getTodoList({
    required User user,
  }) async {
    List<Map<dynamic, dynamic>> list = [];
    Map<dynamic, Map<dynamic, dynamic>> result = {};
    final snapshot = await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(user.uid)
        .collection('todo_collection')
        .orderBy('title')
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              Map<dynamic, dynamic> value = {};
              value['title'] = element['title'];
              value['deadline'] = element['deadline'];
              value['priority'] = element['priority'];
              list.add(value);
            },
          ),
        );
    var i = 0;
    for (var value in list) {
      result[i++] = value;
    }
    return result;
  }

  Future<String> createTodoListDocument({
    required User user,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(user.uid)
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
    required User user,
    required String name,
    required String password,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'user_collection',
        )
        .doc(user.uid)
        .set({
      'name': name,
      'password': password,
    });
    return 'success';
  }
}
