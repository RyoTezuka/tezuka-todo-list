import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/model/TodoModel.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/create_modify/todo_create_modify_screen_page.dart';
import 'package:todo_management/screen/detail/todo_detail_screen_page.dart';
import 'package:todo_management/screen/list/bloc/todo_list_screen.dart';

class TodoListScreenPage extends StatefulWidget {
  const TodoListScreenPage({
    Key? key,
    required this.title,
    required this.name,
  }) : super(key: key);
  final String title;
  final String name;

  @override
  State<TodoListScreenPage> createState() => _TodoListState();
}

class _TodoListState extends State<TodoListScreenPage> {
  late TodoListScreenBloc _bloc;

  late FirebaseAuthDataProvider _firebaseAuthDataProvider;
  late FirebaseTodoDataProvider _firebaseTodoDataProvider;
  late AuthRepository _authRepository;
  late TodoRepository _todoRepository;

  late List<TodoModel> _todoData;

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

    _todoData = [];

    _bloc = TodoListScreenBloc(
      authRepository: _authRepository,
      todoRepository: _todoRepository,
    );
    _bloc.add(
      OnRequestedInitializeEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (context, state) async {
        // ????????????
        if (state is InitializeSuccessState) {
          _todoData = state.todoData;
          _bloc.add(
            OnCompletedRenderEvent(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        '?????????????????? ' + widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true, //??????
                  physics: const NeverScrollableScrollPhysics(), //??????
                  itemCount: _todoData.length,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    return Container(
                      color: Colors.lightGreenAccent,
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: ListTile(
                        title: Text('???????????????${_todoData[index].title}'),
                        subtitle: Text(
                            '????????????${_todoData[index].priority}\n?????????:${_todoData[index].deadline}'),
                        trailing: const Icon(Icons.more_vert),
                        leading: const Icon(Icons.movie, color: Colors.pink),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodoDetailScreenPage(
                                title: 'TODO??????\nTODO??????',
                                name: widget.name,
                                todoId: _todoData[index].todoId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TodoCreateModifyScreenPage(
                    title: 'TODO??????\nTODO???????????????',
                    name: widget.name,
                    todoId: '',
                  ),
                ),
              ),
            },
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
