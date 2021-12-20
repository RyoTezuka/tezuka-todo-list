import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/create_modify/bloc/todo_create_modify_screen.dart';
import 'package:todo_management/util/date_format_util.dart';

import 'todo_create_modify_screen_bloc_test.mocks.dart';

@GenerateMocks([
  FirebaseAuthDataProvider,
  FirebaseTodoDataProvider,
])
void main() {
  const userCollection = "user_collection";
  const todoCollection = "todo_collection";

  final _firebaseAuthDataProvider = MockFirebaseAuthDataProvider();
  final _firebaseTodoDataProvider = MockFirebaseTodoDataProvider();
  final _authRepository = AuthRepository(
    firebaseAuthDataProvider: _firebaseAuthDataProvider,
  );
  final _todoRepository = TodoRepository(
    firebaseTodoDataProvider: _firebaseTodoDataProvider,
    firebaseAuthDataProvider: _firebaseAuthDataProvider,
  );

  late TodoCreateModifyScreenBloc _bloc;

  setUp(() {
    _bloc = TodoCreateModifyScreenBloc(
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
        assert(bloc.toString() == "TODO登録更新画面");
      },
    );
  });

  group("OnRequestedInitializeEvent", () {
    const testEmail = "hoge@example.com";
    const testTodoId = "todoId";
    final testUser = MockUser(
      email: testEmail,
    );
    final testUid = testUser.uid;

    group("1. 正常系", () {
      blocTest(
        "1-1. 新規登録の場合",
        build: () => _bloc,
        act: (dynamic bloc) async {
          bloc.add(
            const OnRequestedInitializeEvent(
              todoId: "",
            ),
          );
        },
        expect: () => [
          InitializeInProgressState(),
          isA<InitializeSuccessState>(),
        ],
        verify: (dynamic bloc) async {},
      );

      blocTest(
        "1-2. 更新の場合",
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

  group("ChangeDateTimeState", () {
    blocTest(
      "1. 日付変更正常終了",
      build: () => _bloc,
      act: (dynamic bloc) async {
        bloc.add(
          OnChangeDateTimeEvent(
            dateTime: DateTime.now(),
          ),
        );
      },
      expect: () => [
        isA<ChangeDateTimeState>(),
      ],
      verify: (dynamic bloc) async {},
    );
  });

  group("OnChangeTimeOfDayEvent", () {
    blocTest(
      "1. 時間変更正常終了",
      build: () => _bloc,
      act: (dynamic bloc) async {
        bloc.add(
          OnChangeTimeOfDayEvent(
            timeOfDay: TimeOfDay.now(),
          ),
        );
      },
      expect: () => [
        isA<ChangeTimeOfDayState>(),
      ],
      verify: (dynamic bloc) async {},
    );
  });

  group("OnCreateModifyEvent", () {
    const testEmail = "hoge@example.com";
    final testUser = MockUser(
      email: testEmail,
    );
    final testUid = testUser.uid;

    group("1. 登録更新ボタン押下処理正常系", () {
      blocTest(
        "1-1. 登録処理",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.createTodoDetail(
              uid: anyNamed("uid"),
              title: anyNamed("title"),
              detail: anyNamed("detail"),
              priority: anyNamed("priority"),
              deadline: anyNamed("deadline"),
            ),
          ).thenAnswer(
            (realInvocation) => Future.value("success"),
          );

          bloc.add(
            const OnCreateModifyEvent(
              todoId: "",
              title: "testタイトル",
              detail: "test詳細",
              priority: "S",
              deadline: "2012/12/31 13:00",
            ),
          );
        },
        expect: () => [
          CreateUpdateInProgressState(),
          CreateUpdateSuccessState(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.createTodoDetail(
              uid: testUid,
              title: "testタイトル",
              detail: "test詳細",
              priority: "S",
              deadline: "2012/12/31 13:00",
            ),
          );
        },
      );

      blocTest(
        "1-2. 更新処理",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.updateTodoDetail(
              uid: anyNamed("uid"),
              todoId: anyNamed("todoId"),
              title: anyNamed("title"),
              detail: anyNamed("detail"),
              priority: anyNamed("priority"),
              deadline: anyNamed("deadline"),
            ),
          ).thenAnswer(
            (realInvocation) => Future.value("success"),
          );

          bloc.add(
            const OnCreateModifyEvent(
              todoId: "todoId",
              title: "testタイトル",
              detail: "test詳細",
              priority: "S",
              deadline: "2012/12/31 13:00",
            ),
          );
        },
        expect: () => [
          CreateUpdateInProgressState(),
          CreateUpdateSuccessState(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.updateTodoDetail(
              uid: testUid,
              todoId: "todoId",
              title: "testタイトル",
              detail: "test詳細",
              priority: "S",
              deadline: "2012/12/31 13:00",
            ),
          );
        },
      );
    });

    group("2. 登録更新ボタン押下処理異常系", () {
      blocTest(
        "2-1. 登録処理異常",
        build: () => _bloc,
        act: (dynamic bloc) async {
          when(
            _firebaseAuthDataProvider.getCurrentUser(),
          ).thenAnswer(
            (realInvocation) async => testUser,
          );

          when(
            _firebaseTodoDataProvider.createTodoDetail(
              uid: anyNamed("uid"),
              title: anyNamed("title"),
              detail: anyNamed("detail"),
              priority: anyNamed("priority"),
              deadline: anyNamed("deadline"),
            ),
          ).thenThrow(
            FirebaseException(code: "unexpected_error", plugin: ""),
          );

          bloc.add(
            const OnCreateModifyEvent(
              todoId: "",
              title: "testタイトル",
              detail: "test詳細",
              priority: "S",
              deadline: "2012/12/31 13:00",
            ),
          );
        },
        expect: () => [
          CreateUpdateInProgressState(),
          isA<CreateUpdateFailureState>(),
        ],
        verify: (dynamic bloc) async {
          verify(
            _firebaseTodoDataProvider.createTodoDetail(
              uid: testUid,
              title: "testタイトル",
              detail: "test詳細",
              priority: "S",
              deadline: "2012/12/31 13:00",
            ),
          );
        },
      );
    });

    blocTest(
      "2-2. 更新処理異常",
      build: () => _bloc,
      act: (dynamic bloc) async {
        when(
          _firebaseAuthDataProvider.getCurrentUser(),
        ).thenAnswer(
          (realInvocation) async => testUser,
        );

        when(
          _firebaseTodoDataProvider.updateTodoDetail(
            uid: anyNamed("uid"),
            todoId: anyNamed("todoId"),
            title: anyNamed("title"),
            deadline: anyNamed("deadline"),
            detail: anyNamed("detail"),
            priority: anyNamed("priority"),
          ),
        ).thenThrow(
          Error(),
        );

        bloc.add(
          const OnCreateModifyEvent(
            todoId: "todoId",
            title: "testタイトル",
            detail: "test詳細",
            priority: "S",
            deadline: "2012/12/31 13:00",
          ),
        );
      },
      expect: () => [
        CreateUpdateInProgressState(),
        isA<CreateUpdateFailureState>(),
      ],
      verify: (dynamic bloc) async {
        verify(
          _firebaseTodoDataProvider.updateTodoDetail(
            uid: testUid,
            todoId: "todoId",
            title: "testタイトル",
            detail: "test詳細",
            priority: "S",
            deadline: "2012/12/31 13:00",
          ),
        );
      },
    );
  });
}
