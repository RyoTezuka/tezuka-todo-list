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
import 'package:todo_management/screen/detail/bloc/todo_detail_screen.dart';
import 'package:todo_management/util/date_format_util.dart';

import 'todo_detail_screen_bloc_test.mocks.dart';

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

  late TodoDetailScreenBloc _bloc;

  setUp(() {
    _bloc = TodoDetailScreenBloc(
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
        assert(bloc.toString() == "TODO詳細画面");
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
        "1-1. 正常終了する場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.getTodoDetail(
              uid: anyNamed("uid"),
              todoId: anyNamed("todoId"),
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
                  .doc(testTodoId)
                  .get();
            },
          );
          bloc.add(
            const OnRequestedInitializeEvent(
              todoId: testTodoId,
            ),
          );
        },
        expect: () => [
          InitializeInProgressState(),
          isA<InitializeSuccessState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.getTodoDetail(
              uid: testUid,
              todoId: testTodoId,
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
            _firebaseTodoDataProvider.getTodoDetail(
              uid: anyNamed("uid"),
              todoId: anyNamed("todoId"),
            ),
          ).thenThrow(
            FirebaseException(code: "invalid-name", plugin: ""),
          );
          bloc.add(
            const OnRequestedInitializeEvent(
              todoId: testTodoId,
            ),
          );
        },
        expect: () => [
          InitializeInProgressState(),
          isA<InitializeFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.getTodoDetail(
              uid: testUid,
              todoId: testTodoId,
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

  group("OnRequestedUpdateEvent", () {
    blocTest(
      "1. 更新処理移動",
      build: () => _bloc,
      act: (dynamic bloc) async {
        bloc.add(
          const OnRequestedUpdateEvent(
            todoId: "todoId",
          ),
        );
      },
      expect: () => [
        UpdateInProgressState(),
      ],
      verify: (dynamic bloc) async {},
    );
  });

  group("OnRequestedDeleteEvent", () {
    const testEmail = "hoge@example.com";
    const testTodoId = "todoId";
    final testUser = MockUser(
      email: testEmail,
    );

    group("1. 正常系", () {
      blocTest(
        "1-1. 削除処理",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.deleteTodoDetail(
              uid: anyNamed("uid"),
              todoId: anyNamed("todoId"),
            ),
          ).thenAnswer(
            (realInvocation) async => "success",
          );

          bloc.add(
            const OnRequestedDeleteEvent(
              todoId: testTodoId,
            ),
          );
        },
        expect: () => [
          DeleteInProgressState(),
          DeleteSuccessState(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.deleteTodoDetail(
              uid: testUser.uid,
              todoId: testTodoId,
            ),
          );
        },
      );
    });

    group("2. 異常系", () {
      blocTest(
        "2-1. 削除処理異常",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.deleteTodoDetail(
              uid: anyNamed("uid"),
              todoId: anyNamed("todoId"),
            ),
          ).thenThrow(
            Error(),
          );

          bloc.add(
            const OnRequestedDeleteEvent(
              todoId: testTodoId,
            ),
          );
        },
        expect: () => [
          DeleteInProgressState(),
          isA<DeleteFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.deleteTodoDetail(
              uid: testUser.uid,
              todoId: testTodoId,
            ),
          );
        },
      );
    });
  });
}
