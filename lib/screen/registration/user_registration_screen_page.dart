import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_management/data_provider/firebase_auth_data_provider.dart';
import 'package:todo_management/repository/auth_repository.dart';
import 'package:todo_management/screen/list/todo_list_screen_page.dart';
import 'package:todo_management/screen/registration/bloc/user_registration_screen.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  String _text = '';
  String _name = '';

  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  late TextEditingController _nameTextEditingController;
  late TextEditingController _passwordTextEditingController;

  late FirebaseAuthDataProvider _firebaseAuthDataProvider;
  late AuthRepository _authRepository;
  late RegistrationScreenBloc _bloc;

  late String _errortext;

  Future<String> fetchName() async {
    final snapshot = await FirebaseFirestore.instance.collection('user_collection').get();
    final name = snapshot.docs.first.data()['name'];
    print(name);
    return name;
  }

  @override
  void initState() {
    super.initState();

    _nameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();

    _firebaseAuthDataProvider = FirebaseAuthDataProvider();
    _authRepository = AuthRepository(
      firebaseAuthDataProvider: _firebaseAuthDataProvider,
    );
    _bloc = RegistrationScreenBloc(
      authRepository: _authRepository,
    );

    _bloc.add(
      OnRequestedInitializeEvent(),
    );

    _errortext = '';
    fetchName().then(
      (value) => _name = value,
    );
    print(_name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (context, state) async {
        // 初期化中
        if (state is InitializeSuccessState) {
          _bloc.add(
            OnCompletedRenderEvent(),
          );
        }

        // 認証中
        else if (state is CreateUserInProgressState) {
          // ページ中央でクルクルするダイアログ
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

        //  ユーザー登録成功後
        else if (state is CreateUserSuccessState) {
          await Future.delayed(const Duration(seconds: 3));

          // ログイン試行結果を取得
          var hasSuccessedLogin = state.result;

          if (hasSuccessedLogin == 'success') {
            // ローディングダイアログを閉じる
            Navigator.of(context).pop();

            // TODO一覧画面へ遷移する
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TodoList(
                  title: 'TODO監理\nTODO一覧',
                ),
              ),
            );
          }
          // ログインNG
          else {
            // ローディングダイアログを閉じる
            Navigator.of(context).pop();

            _bloc.add(
              OnCompletedRenderEvent(),
            );
          }
        }
        // ログイン試行失敗後
        else if (state is CreateUserFailureState) {
          // エラーメッセージ
          if (state.error.message == "The password provided is too weak.") {
            _errortext = "※パスワードが短か過ぎます。";
          } else if (state.error.message == "The account already exists for that email.") {
            _errortext = "※そのユーザーはすでに存在します。";
          } else {
            _errortext = "※エラーが発生しました。";
          }

          // ローディングダイアログを閉じる
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
                      'ユーザー名',
                    ),
                    TextField(
                      controller: _nameTextEditingController,
                      enabled: true,
                      // 入力数
                      maxLength: 40,
                      style: const TextStyle(color: Colors.black),
                      obscureText: false,
                      maxLines: 1,
                      //パスワード
                      onChanged: _handleText,
                      decoration: const InputDecoration(
                        hintText: '海馬　太郎',
                      ),
                    ),
                    const Text(
                      'パスワード',
                    ),
                    TextField(
                      controller: _passwordTextEditingController,
                      enabled: true,
                      // 入力数
                      maxLength: 40,
                      style: const TextStyle(color: Colors.black),
                      obscureText: true,
                      maxLines: 1,
                      //パスワード
                      onChanged: _handleText,
                    ),
                    SizedBox(
                      // 「ログイン」ボタン
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // イベント発火
                          _bloc.add(
                            OnCreateUserEvent(
                              name: _nameTextEditingController.text,
                              password: _passwordTextEditingController.text,
                            ),
                          );
                        },
                        child: const Text(
                          'ログイン',
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
