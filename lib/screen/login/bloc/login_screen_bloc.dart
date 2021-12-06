import 'package:bloc/bloc.dart';
import 'package:todo_management/screen/login/bloc/login_screen.dart';

class LoginScreenBloc extends Bloc {
  LoginScreenBloc()
      : super(
          InitialState(),
        );

  @override
  String toString() => 'ログイン画面';

  Stream mapEventToState(event) async* {
    // 初期化要求
    if (event is OnRequestedInitializeEvent) {
      yield InitializeInProgressState();

      try {
        // TODO 初期化処理

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
        // TODO 認証処理
        await Future.delayed(const Duration(seconds: 2));

        yield AuthenticateSuccessState();
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
