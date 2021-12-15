import 'package:bloc/bloc.dart';
import 'package:todo_management/model/TodoModel.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/create_modify/bloc/todo_create_modify_screen.dart';

class TodoCreateModifyScreenBloc extends Bloc {
  AuthRepository authRepository;
  TodoRepository todoRepository;

  TodoCreateModifyScreenBloc({
    required this.authRepository,
    required this.todoRepository,
  }) : super(
          InitialState(),
        );

  @override
  String toString() => 'TODO登録更新画面';

  @override
  Stream mapEventToState(event) async* {
    // 初期化要求
    if (event is OnRequestedInitializeEvent) {
      yield InitializeInProgressState();

      try {
        final TodoModel todoDetailData;

        if (event.todoId == '') {
          todoDetailData = const TodoModel(
            todoId: '',
            title: '',
            deadline: '',
            priority: 'A',
            detail: '',
          );
          yield InitializeSuccessState(
            isCreate: true,
            todoDetailData: todoDetailData,
          );
        }

        // 詳細情報取得
        else {
          // TODO詳細情報取得
          todoDetailData = await todoRepository.getTodoData(
            todoId: event.todoId,
          );
          yield InitializeSuccessState(
            isCreate: false,
            todoDetailData: todoDetailData,
          );
        }
      } catch (e, s) {
        print(e);
        print(s);
        yield InitializeFailureState(
          error: e,
          stackTrace: s,
        );
      }
    }
    // 日付変更
    else if (event is OnChangeDateTimeEvent) {
      yield ChangeDateTimeState(dateTime: event.dateTime);
    }
    // 時間変更
    else if (event is OnChangeTimeOfDayEvent) {
      yield ChangeTimeOfDayState(timeOfDay: event.timeOfDay);
    }
    // 描画完了
    else if (event is OnCompletedRenderEvent) {
      yield IdleState();
    }

    // 更新処理
    else if (event is OnCreateModifyEvent) {
      yield CreateUpdateInProgressState();

      try {
        TodoModel data = TodoModel(
          todoId: event.todoId,
          title: event.title,
          deadline: event.deadline,
          priority: event.priority,
          detail: event.detail,
        );

        // 登録処理
        if (event.todoId == '') {
          await todoRepository.createTodoData(
            todoData: data,
          );
        }

        // 更新処理
        else {
          await todoRepository.updateTodoData(
            todoData: data,
          );
        }

        yield CreateUpdateSuccessState();
      } catch (e, s) {
        print(e);
        print(s);
        yield CreateUpdateFailureState(
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
