import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/model/TodoModel.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/create_modify/bloc/todo_create_modify_screen.dart';
import 'package:todo_management/screen/list/todo_list_screen_page.dart';
import 'package:todo_management/util/date_format_util.dart';

class TodoCreateModifyScreenPage extends StatefulWidget {
  const TodoCreateModifyScreenPage({
    Key? key,
    required this.title,
    required this.name,
    required this.todoId,
  }) : super(key: key);
  final String title;
  final String name;
  final String todoId;

  @override
  State<TodoCreateModifyScreenPage> createState() => _TodoCreateModifyScreenPageState();
}

class _TodoCreateModifyScreenPageState extends State<TodoCreateModifyScreenPage> {
  late TextEditingController _titleTextEditingController;
  late TextEditingController _detailTextEditingController;

  late TodoCreateModifyScreenBloc _bloc;
  late FirebaseAuthDataProvider _firebaseAuthDataProvider;
  late FirebaseTodoDataProvider _firebaseTodoDataProvider;
  late AuthRepository _authRepository;
  late TodoRepository _todoRepository;
  late TodoModel _todoDetailData;

  String dropdownValue = 'A';
  final dropdownItem = <String>[
    'SS',
    'S',
    'A',
    'B',
    'C',
  ].map<DropdownMenuItem<String>>((
    String value,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();
  String deadline = '';

  DateTime _date = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2016),
        lastDate: DateTime.now().add(const Duration(days: 360)));
    if (picked != null) {
      _bloc.add(
        OnChangeDateTimeEvent(dateTime: picked),
      );
    }
  }

  TimeOfDay _time = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      _bloc.add(
        OnChangeTimeOfDayEvent(timeOfDay: picked),
      );
    }
  }

  String toDateTime(DateTime dateTime, TimeOfDay timeOfDay) {
    return formatDateTimeToString(
      dDateTime: DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        timeOfDay.hour,
        timeOfDay.minute,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _titleTextEditingController = TextEditingController();
    _detailTextEditingController = TextEditingController();

    _firebaseAuthDataProvider = FirebaseAuthDataProvider();
    _firebaseTodoDataProvider = FirebaseTodoDataProvider();

    _authRepository = AuthRepository(
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );
    _todoRepository = TodoRepository(
      firebaseTodoDataProvider: _firebaseTodoDataProvider,
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );

    _bloc = TodoCreateModifyScreenBloc(
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
        // 初期化成功後
        if (state is InitializeSuccessState) {
          _todoDetailData = state.todoDetailData;
          _titleTextEditingController.text = _todoDetailData.title;
          dropdownValue = _todoDetailData.priority;
          _detailTextEditingController.text = _todoDetailData.detail;

          // 新規登録
          if (state.isCreate) {
            deadline = toDateTime(_date, _time);
          }
          // 更新
          else {
            deadline = _todoDetailData.deadline;
          }

          _bloc.add(
            OnCompletedRenderEvent(),
          );
        }
        // 更新処理完了
        else if (state is CreateUpdateSuccessState) {
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
        // 日付変更
        else if (state is ChangeDateTimeState) {
          _date = state.dateTime;
          deadline = toDateTime(_date, _time);

          _bloc.add(
            OnCompletedRenderEvent(),
          );
        }
        // 時間変更
        else if (state is ChangeTimeOfDayState) {
          _time = state.timeOfDay;
          deadline = toDateTime(_date, _time);

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
                  height: 550,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          const Text('タイトル: '),
                          Container(
                            width: 250,
                            color: Colors.white,
                            child: TextField(
                              controller: _titleTextEditingController,
                              enabled: true,
                              style: const TextStyle(color: Colors.black),
                              obscureText: false,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('期日: $deadline'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: const Text(
                                  '日付選択',
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () => _selectTime(context),
                                child: const Text(
                                  '時間選択',
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('優先順位:  '),
                          DropdownButton<String>(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: dropdownItem,
                          ),
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
                        height: 250,
                        child: Container(
                          color: Colors.white,
                          child: SizedBox(
                            width: 290,
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: _detailTextEditingController,
                              style: const TextStyle(
                                decorationColor: Colors.transparent,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      // 「登録」ボタン
                      width: 150,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // イベント発火
                          _bloc.add(
                            OnCreateModifyEvent(
                              todoId: widget.todoId,
                              title: _titleTextEditingController.text,
                              detail: _detailTextEditingController.text,
                              priority: dropdownValue,
                              deadline: deadline,
                            ),
                          );
                        },
                        child: const Text(
                          '登録',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
