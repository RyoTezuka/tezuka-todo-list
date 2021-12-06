import 'package:flutter/material.dart';

import 'package:todo_management/screen/list/todo_list.dart';
import 'package:todo_management/screen/login/bloc/login_screen.dart';
import 'package:todo_management/screen/login/bloc/login_screen_bloc.dart';
import 'package:todo_management/screen/registration/user_registration.dart';

// void main() => runApp(const TODOManagementApp());

class TODOManagementApp extends StatelessWidget {
  const TODOManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreenPage(title: 'TODO管理\nログイン'),
    );
  }
}

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginScreenPage> createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  String _text = '';

  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  late LoginScreenBloc _bloc;

  @override
  void initState() {
    _bloc = LoginScreenBloc();

    _bloc.add(
      const OnRequestedAuthenticateEvent(name: '', password: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return BlocConsumer();

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
                const SizedBox(
                  height: 50,
                  child: Text(
                    '※ユーザー名かパスワードが間違っています。',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                const Text(
                  'ユーザー名',
                ),
                TextField(
                  enabled: true,
                  // 入力数
                  maxLength: 10,
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
                  enabled: true,
                  // 入力数
                  maxLength: 10,
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TODOList(
                            title: 'TODO管理\nTODO一覧',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'ログイン',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'まだユーザー登録していない方はコチラ',
                ),
                SizedBox(
                  // 「ユーザー新規登録」ボタン
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UserRegistration(
                            title: 'TODO管理\nユーザー登録',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'ユーザー新規登録',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
