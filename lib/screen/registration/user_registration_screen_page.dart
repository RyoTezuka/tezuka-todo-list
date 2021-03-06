import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/data_provider/firebase_todo_data_provider.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/repository/todo_repository.dart';
import 'package:todo_management/screen/list/todo_list_screen_page.dart';
import 'package:todo_management/screen/registration/bloc/user_registration_screen.dart';

class UserRegistrationScreenPage extends StatefulWidget {
  const UserRegistrationScreenPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<UserRegistrationScreenPage> createState() => _UserRegistrationScreenPageState();
}

class _UserRegistrationScreenPageState extends State<UserRegistrationScreenPage> {
  late TextEditingController _nameTextEditingController;
  late TextEditingController _passwordTextEditingController;

  late FirebaseAuthDataProvider _firebaseAuthDataProvider;
  late FirebaseTodoDataProvider _firebaseTodoDataProvider;
  late AuthRepository _authRepository;
  late TodoRepository _todoRepository;
  late RegistrationScreenBloc _bloc;

  late String _errortext;

  @override
  void initState() {
    super.initState();

    _nameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();

    _firebaseAuthDataProvider = FirebaseAuthDataProvider();
    _authRepository = AuthRepository(
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );
    _firebaseTodoDataProvider = FirebaseTodoDataProvider();
    _todoRepository = TodoRepository(
      firebaseTodoDataProvider: _firebaseTodoDataProvider,
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );

    _bloc = RegistrationScreenBloc(
      authRepository: _authRepository,
      todoRepository: _todoRepository,
    );

    _bloc.add(
      OnRequestedInitializeEvent(),
    );

    _errortext = '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (context, state) async {
        // ????????????
        if (state is InitializeSuccessState) {
          _bloc.add(
            OnCompletedRenderEvent(),
          );
        }

        // ?????????
        else if (state is CreateUserInProgressState) {
          // ???????????????????????????????????????????????????
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            transitionDuration: const Duration(milliseconds: 300),
            barrierColor: Colors.black.withOpacity(0.5),
            pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }

        //  ???????????????????????????
        else if (state is CreateUserSuccessState) {
          await Future.delayed(const Duration(seconds: 3));

          // ?????????????????????????????????
          final hasSuccessedLogin = state.result;

          if (hasSuccessedLogin == 'success') {
            // ?????????????????????????????????????????????
            Navigator.of(context).pop();

            // TODO???????????????????????????
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TodoListScreenPage(
                  title: 'TODO??????\nTODO??????',
                  name: _nameTextEditingController.text,
                ),
              ),
            );
          }
          // ????????????NG
          else {
            // ?????????????????????????????????????????????
            Navigator.of(context).pop();

            _bloc.add(
              OnCompletedRenderEvent(),
            );
          }
        }
        // ???????????????????????????
        else if (state is CreateUserFailureState) {
          // ????????????????????????
          if (state.error.message == "The password provided is too weak.") {
            _errortext = "??????????????????????????????????????????";
          } else if (state.error.message == "The account already exists for that email.") {
            _errortext = "???????????????????????????????????????????????????";
          } else {
            _errortext = "????????????????????????????????????";
          }

          // ?????????????????????????????????????????????
          Navigator.of(context).pop();

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
          body: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                      child: Text(
                        _errortext,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const Text(
                      '???????????????',
                    ),
                    TextField(
                      controller: _nameTextEditingController,
                      enabled: true,
                      // ?????????
                      maxLength: 40,
                      style: const TextStyle(color: Colors.black),
                      obscureText: false,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'todo_taro@test00.jp',
                      ),
                    ),
                    const Text(
                      '???????????????',
                    ),
                    TextField(
                      controller: _passwordTextEditingController,
                      enabled: true,
                      // ?????????
                      maxLength: 40,
                      style: const TextStyle(color: Colors.black),
                      obscureText: true,
                      maxLines: 1,
                    ),
                    SizedBox(
                      // ???????????????????????????
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // ??????????????????
                          _bloc.add(
                            OnRequestedCreateUserEvent(
                              name: _nameTextEditingController.text,
                              password: _passwordTextEditingController.text,
                            ),
                          );
                        },
                        child: const Text(
                          '????????????',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
