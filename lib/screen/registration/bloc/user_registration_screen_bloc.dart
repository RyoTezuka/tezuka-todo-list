import 'package:bloc/bloc.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/registration/bloc/user_registration_screen_event.dart';
import 'package:todo_management/screen/registration/bloc/user_registration_screen_state.dart';

class RegistrationScreenBloc extends Bloc {
  AuthRepository authRepository;
  TodoRepository todoRepository;

  RegistrationScreenBloc({
    required this.authRepository,
    required this.todoRepository,
  }) : super(
          InitialState(),
        );

  @override
  String toString() => 'ユーザー登録画面';

  @override
  Stream mapEventToState(event) async* {
    // 初期化要求
    if (event is OnRequestedInitializeEvent) {
      yield InitializeInProgressState();

      try {
        yield InitializeSuccessState();
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

    // 認証要求
    else if (event is OnRequestedCreateUserEvent) {
      yield CreateUserInProgressState();

      try {
        // ユーザー登録
        final registrationResult = await authRepository.registration(
          email: event.name,
          password: event.password,
        );
        if (registrationResult == "The password provided is too weak.") {
          throw Exception(registrationResult);
        } else if (registrationResult == "The account already exists for that email.") {
          throw Exception(registrationResult);
        } else if (registrationResult != "success") {
          throw Exception(registrationResult);
        }

        // ユーザーデータをユーザーコレクションへ追加
        final createUserCollectionData = await todoRepository.createUserData(
          email: event.name,
          password: event.password,
        );

        // ログイン
        final loginResult = await authRepository.login(
          email: event.name,
          password: event.password,
        );
        if (loginResult != "success") {
          throw Exception(loginResult);
        }
        yield CreateUserSuccessState(
          result: loginResult,
        );
      } catch (e, s) {
        print(e);
        print(s);
        yield CreateUserFailureState(
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
