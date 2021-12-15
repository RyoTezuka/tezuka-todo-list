import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/model/TodoModel.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/create_modify/todo_create_modify_screen_page.dart';
import 'package:todo_management/screen/detail/bloc/todo_detail_screen.dart';
import 'package:todo_management/screen/list/todo_list_screen_page.dart';

class TodoDetailScreenPage extends StatefulWidget {
  const TodoDetailScreenPage({
    Key? key,
    required this.title,
    required this.name,
    required this.todoId,
  }) : super(key: key);
  final String title;
  final String name;
  final String todoId;

  @override
  State<TodoDetailScreenPage> createState() => _TodoDetailScreenPageState();
}

class _TodoDetailScreenPageState extends State<TodoDetailScreenPage> {
  late TodoDetailScreenBloc _bloc;
  late FirebaseAuthDataProvider _firebaseAuthDataProvider;
  late FirebaseTodoDataProvider _firebaseTodoDataProvider;
  late AuthRepository _authRepository;
  late TodoRepository _todoRepository;
  late TodoModel _todoDetailData;

  @override
  void initState() {
    super.initState();

    _firebaseAuthDataProvider = FirebaseAuthDataProvider();
    _firebaseTodoDataProvider = FirebaseTodoDataProvider();

    _authRepository = AuthRepository(
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );
    _todoRepository = TodoRepository(
      firebaseTodoDataProvider: _firebaseTodoDataProvider,
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );

    _bloc = TodoDetailScreenBloc(
      authRepository: _authRepository,
      todoRepository: _todoRepository,
    );
    _todoDetailData = const TodoModel(
      todoId: '',
      title: '',
      deadline: '',
      priority: '',
      detail: '',
    );
    _bloc.add(
      OnRequestedInitializeEvent(
        name: widget.name,
        todoId: widget.todoId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (context, state) async {
        // 初期化中
        if (state is InitializeSuccessState) {
          _todoDetailData = state.todoDetailData;
          _bloc.add(
            OnCompletedRenderEvent(),
          );
        }

        // 削除成功
        else if (state is DeleteSuccessState) {
          // TODO一覧画面へ遷移する
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TodoListScreenPage(
                title: 'TODO管理\nTODO一覧',
                name: widget.name,
              ),
            ),
          );
        }

        // 更新
        else if (state is UpdateInProgressState) {
          // TODO登録更新画面へ遷移する
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TodoCreateModifyScreenPage(
                title: 'TODO管理\nユーザー更新',
                name: widget.name,
                todoId: widget.todoId,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'ユーザー名： ' + widget.name,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    padding: const EdgeInsets.all(20),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.lightGreenAccent,
                width: 350,
                height: 500,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Text('タイトル:  ${_todoDetailData.title}'),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text('期日:  ${_todoDetailData.deadline}'),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text('優先順位:  ${_todoDetailData.priority}'),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: const [
                        Text('内容：'),
                      ],
                    ),
                    SizedBox(
                      width: 300,
                      height: 325,
                      child: Container(
                        color: Colors.white,
                        child: Text(_todoDetailData.detail),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // 「更新」ボタン
                    width: 150,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // イベント発火
                        _bloc.add(
                          OnRequestedUpdateEvent(
                            todoId: widget.todoId,
                          ),
                        );
                      },
                      child: const Text(
                        '更新',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    // 「削除」ボタン
                    width: 150,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // イベント発火
                        _bloc.add(
                          OnRequestedDeleteEvent(
                            todoId: widget.todoId,
                          ),
                        );
                      },
                      child: const Text(
                        '削除',
                      ),
                    ),
                  )
                ],
              ),
            ],
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
