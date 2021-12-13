import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/detail/bloc/todo_detail_screen.dart';

class TodoDetailScreenBloc extends Bloc {
  AuthRepository authRepository;
  TodoRepository todoRepository;

  TodoDetailScreenBloc({
    required this.authRepository,
    required this.todoRepository,
  }) : super(
          InitialState(),
        );

  @override
  String toString() => 'TODO詳細画面';

  @override
  Stream mapEventToState(event) async* {
    Intl.defaultLocale = "ja_JP";
    initializeDateFormatting("ja_JP");
    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm", "ja_JP");

    // 初期化要求
    if (event is OnRequestedInitializeEvent) {
      yield InitializeInProgressState();

      try {
        // TODO詳細情報取得
        final todoDetailData = await todoRepository.getTodoData(
          id: event.id,
        );
        todoDetailData!['deadline'] = dateFormat.format(todoDetailData['deadline'].toDate());

        yield InitializeSuccessState(
          todoDetailData: todoDetailData,
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

    // 編集画面
    else if (event is OnRequestedUpdateEvent) {
      yield UpdateInProgressState();
    }

    // 削除処理
    else if (event is OnRequestedDeleteEvent) {
      yield DeleteInProgressState();

      try {
        // TODO詳細情報削除
        final todoDetailData = await todoRepository.deleteTodoData(
          id: event.id,
        );

        yield DeleteSuccessState();
      } catch (e, s) {
        print(e);
        print(s);
        yield DeleteFailureState(
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
