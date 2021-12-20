import 'package:bloc/bloc.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/screen/login/bloc/login_screen.dart';

class LoginScreenBloc extends Bloc {
  AuthRepository authRepository;

  LoginScreenBloc({
    required this.authRepository,
  }) : super(
          InitialState(),
        );

  @override
  String toString() => 'ログイン画面';

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
    else if (event is OnRequestedAuthenticateEvent) {
      yield AuthenticateInProgressState();

      try {
        final result = await authRepository.login(
          email: event.name,
          password: event.password,
        );
        if (result == "unexpected_error") {
          throw Error();
        } else if (result == "invalid_name") {
          throw Error();
        } else if (result == "user_disabled") {
          throw Error();
        }
        yield AuthenticateSuccessState(
          result: result,
        );
      } catch (e, s) {
        print(e);
        print(s);
        yield AuthenticateFailureState(
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
