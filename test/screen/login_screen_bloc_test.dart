import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/screen/login/bloc/login_screen_bloc.dart';
import 'package:todo_management/screen/login/bloc/login_screen_event.dart';
import 'package:todo_management/screen/login/bloc/login_screen_state.dart';

import 'login_screen_bloc_test.mocks.dart';

@GenerateMocks([
  FirebaseAuthDataProvider,
])
void main() {
  final _firebaseAuthDataProvider = MockFirebaseAuthDataProvider();
  final _authRepository = AuthRepository(
    firebaseAuthDataProvider: _firebaseAuthDataProvider,
  );

  late LoginScreenBloc _bloc;

  setUp(() {
    _bloc = LoginScreenBloc(
      authRepository: _authRepository,
    );
  });

  tearDown(() {
    _bloc.close();
  });

  group("toString", () {
    blocTest(
      "1. 分岐なし",
      build: () => _bloc,
      verify: (dynamic bloc) async {
        // 期待通りの画面名がオーバーライドされていること
        assert(bloc.toString() == "ログイン画面");
      },
    );
  });

  group("OnCompletedRenderEvent", () {
    blocTest(
      "1. 画面描画正常終了",
      build: () => _bloc,
      act: (dynamic bloc) async {
        bloc.add(
          OnCompletedRenderEvent(),
        );
      },
      expect: () => [
        IdleState(),
      ],
      verify: (dynamic bloc) async {},
    );
  });

  group("OnRequestedInitializeEvent", () {
    blocTest(
      "1. 正常終了する場合",
      build: () => _bloc,
      act: (dynamic bloc) async {
        bloc.add(
          OnRequestedInitializeEvent(),
        );
      },
      expect: () => [
        InitializeInProgressState(),
        InitializeSuccessState(),
      ],
      verify: (dynamic bloc) async {},
    );
  });

  group("OnRequestedAuthenticateEvent", () {
    const testEmail = "hoge@example.com";
    const testPassword = "foobar";

    final testUser = MockUser(
      email: testEmail,
    );
    final testAuthObject = MockFirebaseAuth(
      mockUser: testUser,
    );

    group("1. 正常系", () {
      blocTest(
        "1-1. 認証がOKとなる場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed(
                "email",
              ),
              password: anyNamed(
                "password",
              ),
            ),
          ).thenAnswer(
            (realInvocation) => testAuthObject.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );

          bloc.add(
            const OnRequestedAuthenticateEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          AuthenticateInProgressState(),
          const AuthenticateSuccessState(
            result: "success",
          ),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );
    });

    group("2. 異常系", () {
      blocTest(
        "2-1. メールアドレス誤りで認証がNGとなる場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed(
                "email",
              ),
              password: anyNamed(
                "password",
              ),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "invalid-name",
            ),
          );

          bloc.add(
            const OnRequestedAuthenticateEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        // 期待通りのステートが生成されていること
        expect: () => [
          AuthenticateInProgressState(),
          const AuthenticateFailureState(
            error: "invalid_name",
            stackTrace: null,
          ),
        ],
        verify: (dynamic bloc) async {
          // 想定通りの引数で認証処理が呼び出されていること
          verify(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-2. 無効なユーザーによるログイン試行で認証がNGとなる場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed(
                "email",
              ),
              password: anyNamed(
                "password",
              ),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "user_disabled",
            ),
          );

          bloc.add(
            const OnRequestedAuthenticateEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        // 期待通りのステートが生成されていること
        expect: () => [
          AuthenticateInProgressState(),
          const AuthenticateFailureState(
            error: "user_disabled",
            stackTrace: null,
          ),
        ],
        verify: (dynamic bloc) async {
          // 想定通りの引数で認証処理が呼び出されていること
          verify(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-3. 予期せぬ理由で認証がNGとなる場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed(
                "email",
              ),
              password: anyNamed(
                "password",
              ),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "unexpected_error",
            ),
          );

          bloc.add(
            const OnRequestedAuthenticateEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        // 期待通りのステートが生成されていること
        expect: () => [
          AuthenticateInProgressState(),
          const AuthenticateFailureState(
            error: "unexpected_error",
            stackTrace: null,
          ),
        ],
        verify: (dynamic bloc) async {
          // 想定通りの引数で認証処理が呼び出されていること
          verify(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-4. 予期せぬエラーが発生した場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed(
                "email",
              ),
              password: anyNamed(
                "password",
              ),
            ),
          ).thenThrow("error");

          bloc.add(
            const OnRequestedAuthenticateEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        // 期待通りのステートが生成されていること
        expect: () => [
          AuthenticateInProgressState(),
          const AuthenticateFailureState(
            error: "unexpected_error",
            stackTrace: null,
          ),
        ],
        verify: (dynamic bloc) async {
          // 想定通りの引数で認証処理が呼び出されていること
          verify(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );
    });
  });
}
