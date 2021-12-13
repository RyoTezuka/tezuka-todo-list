import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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

  @override
  String toString() => 'TODO一覧画面';

  @override
  Stream mapEventToState(event) async* {
    // 初期化要求
    if (event is OnRequestedInitializeEvent) {
      yield InitializeInProgressState();

      try {
        Map<dynamic, dynamic>? todoData = await todoRepository.getTodoList();

        Intl.defaultLocale = "ja_JP";
        initializeDateFormatting("ja_JP");
        DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm", "ja_JP");
        for (Map todo in todoData!.values) {
          todo['deadline'] = dateFormat.format(todo['deadline'].toDate());
        }

        yield InitializeSuccessState(
          todoData: todoData,
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
