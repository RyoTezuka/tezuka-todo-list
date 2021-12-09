import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/list/bloc/todo_list_screen.dart';

class TodoListScreenBloc extends Bloc {
  AuthRepository authRepository;
  TodoRepository todoRepository;

  TodoListScreenBloc({
    required this.authRepository,
    required this.todoRepository,
  }) : super(
          InitialState(),
        );

  late String _name = '';
  Future<String> fetchName() async {
    final snapshot = await FirebaseFirestore.instance.collection('user_collection').get();
    final name = snapshot.docs.first.data()['name'];
    print(name);
    return name;
  }

  @override
  String toString() => 'TODO一覧画面';

  @override
  Stream mapEventToState(event) async* {
    // 初期化要求
    if (event is OnRequestedInitializeEvent) {
      yield InitializeInProgressState();

      _name = event.props[0].toString();
      try {
        Map<dynamic, dynamic>? todoData = await todoRepository.getTodoData();

        yield InitializeSuccessState(
          todoData: todoData!,
        );
      } catch (e, s) {
        print(e);
        print(s);
        yield InitializeFailureState(
          error: e,
          stackTrace: s,
        );
      }
    }

    // 描画完了
    else if (event is OnCompletedRenderEvent) {
      yield IdleState();
    }
  }
}
