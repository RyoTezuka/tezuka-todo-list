import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/list/bloc/todo_list_screen.dart';
import 'package:todo_management/util/date_format_util.dart';

import 'todo_list_screen_bloc_test.mocks.dart';

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

  late TodoListScreenBloc _bloc;

  setUp(() {
    _bloc = TodoListScreenBloc(
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
        assert(bloc.toString() == "TODO一覧画面");
      },
    );
  });

  group("OnRequestedInitializeEvent", () {
    const testEmail = "hoge@example.com";
    const testTodoId = "todoId";
    const userCollection = "user_collection";
    const todoCollection = "todo_collection";
    final testUser = MockUser(
      email: testEmail,
    );
    final testUid = testUser.uid;

    group("1. 正常系", () {
      blocTest(
        "1. 正常終了する場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.getTodoList(
              uid: anyNamed("uid"),
            ),
          ).thenAnswer(
            (realInvocation) async {
              final _instance = FakeFirebaseFirestore();
              await _instance
                  .collection(userCollection)
                  .doc(testUid)
                  .collection(todoCollection)
                  .doc(testTodoId)
                  .set({
                "title": "testタイトル",
                "deadline": formatStringToTimestamp(sDateTime: "2021/12/31 12:00"),
                "priority": "A",
                "detail": "test内容",
                "create_timestamp": FieldValue.serverTimestamp(),
              });

              return await _instance
                  .collection(userCollection)
                  .doc(testUid)
                  .collection(todoCollection)
                  .orderBy("deadline")
                  .get();
            },
          );
          bloc.add(
            OnRequestedInitializeEvent(),
          );
        },
        expect: () => [
          InitializeInProgressState(),
          isA<InitializeSuccessState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.getTodoList(
              uid: testUid,
            ),
          );
        },
      );
    });

    group("2. 異常系", () {
      blocTest(
        "2-1. 異常終了",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.getTodoList(
              uid: anyNamed("uid"),
            ),
          ).thenThrow(
            Error(),
          );
          bloc.add(
            OnRequestedInitializeEvent(),
          );
        },
        expect: () => [
          InitializeInProgressState(),
          isA<InitializeFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.getTodoList(
              uid: testUid,
            ),
          );
        },
      );
    });
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
}
