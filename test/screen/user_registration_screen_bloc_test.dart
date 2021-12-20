import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/registration/bloc/user_registration_screen.dart';

import 'user_registration_screen_bloc_test.mocks.dart';

@GenerateMocks([
  FirebaseAuthDataProvider,
  FirebaseTodoDataProvider,
])
void main() {
  final _firebaseAuthDataProvider = MockFirebaseAuthDataProvider();
  final _firebaseTodoDataProvider = MockFirebaseTodoDataProvider();
  final _authRepository = AuthRepository(
    firebaseAuthDataProvider: _firebaseAuthDataProvider,
  );
  final _todoRepository = TodoRepository(
    firebaseTodoDataProvider: _firebaseTodoDataProvider,
    firebaseAuthDataProvider: _firebaseAuthDataProvider,
  );

  late RegistrationScreenBloc _bloc;

  setUp(() {
    _bloc = RegistrationScreenBloc(
      authRepository: _authRepository,
      todoRepository: _todoRepository,
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
        assert(bloc.toString() == "ユーザー登録画面");
      },
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

  group("OnRequestedCreateUserEvent", () {
    const testEmail = "hoge@example.com";
    const testPassword = "foobar";

    final testUser = MockUser(
      email: testEmail,
    );
    final testAuthObject = MockFirebaseAuth(
      mockUser: testUser,
    );
    Future<MockUserCredential> createUserWithEmailAndPassword({
      required String email,
      required String password,
    }) async {
      return MockUserCredential(
        false,
        mockUser: testUser,
      );
    }

    group("1. 正常系", () {
      blocTest(
        "1-1. ユーザー登録成功",
        build: () => _bloc,
        act: (dynamic bloc) async {
          // ユーザー登録
          when(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenAnswer(
            (realInvocation) => createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );

          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.createUserDocument(
              uid: anyNamed("uid"),
              name: testEmail,
            ),
          ).thenAnswer(
            (realInvocation) => Future.value("success"),
          );

          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenAnswer(
            (realInvocation) => testAuthObject.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );

          bloc.add(
            const OnRequestedCreateUserEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          CreateUserInProgressState(),
          const CreateUserSuccessState(
            result: "success",
          ),
        ],
        verify: (dynamic bloc) async {
          // 想定通りの引数で認証処理が呼び出されていること
          verify(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
          verify(
            _firebaseTodoDataProvider.createUserDocument(
              uid: testUser.uid,
              name: testEmail,
            ),
          );
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
        "2-1. ユーザー登録異常終了（パスワードが短すぎる）",
        build: () => _bloc,
        act: (dynamic bloc) async {
          // ユーザー登録
          when(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "weak-password",
            ),
          );
          bloc.add(
            const OnRequestedCreateUserEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          CreateUserInProgressState(),
          isA<CreateUserFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-2. ユーザー登録異常終了（登録しようとしているユーザーが既に存在する）",
        build: () => _bloc,
        act: (dynamic bloc) async {
          // ユーザー登録
          when(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "email-already-in-use",
            ),
          );
          bloc.add(
            const OnRequestedCreateUserEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          CreateUserInProgressState(),
          isA<CreateUserFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-3. ユーザー登録異常終了（成功以外）",
        build: () => _bloc,
        act: (dynamic bloc) async {
          // ユーザー登録
          when(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "failed",
            ),
          );
          bloc.add(
            const OnRequestedCreateUserEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          CreateUserInProgressState(),
          isA<CreateUserFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-4. ユーザー登録異常終了（その他の異常）",
        build: () => _bloc,
        act: (dynamic bloc) async {
          // ユーザー登録
          when(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenThrow("error");

          bloc.add(
            const OnRequestedCreateUserEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          CreateUserInProgressState(),
          isA<CreateUserFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
        },
      );

      blocTest(
        "2-5. ユーザー登録成功後、ログイン失敗",
        build: () => _bloc,
        act: (dynamic bloc) async {
          // ユーザー登録
          when(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenAnswer(
            (realInvocation) => createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );

          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.createUserDocument(
              uid: anyNamed("uid"),
              name: testEmail,
            ),
          ).thenAnswer(
            (realInvocation) => Future.value("failed"),
          );

          when(
            _firebaseAuthDataProvider.signInWithEmailAndPassword(
              email: anyNamed("email"),
              password: anyNamed("password"),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: "user_disabled",
            ),
          );

          bloc.add(
            const OnRequestedCreateUserEvent(
              name: testEmail,
              password: testPassword,
            ),
          );
        },
        expect: () => [
          CreateUserInProgressState(),
          isA<CreateUserFailureState>(),
        ],
        verify: (dynamic bloc) async {
          // 想定通りの引数で認証処理が呼び出されていること
          verify(
            _firebaseAuthDataProvider.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          );
          verify(
            _firebaseTodoDataProvider.createUserDocument(
              uid: testUser.uid,
              name: testEmail,
            ),
          );
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
