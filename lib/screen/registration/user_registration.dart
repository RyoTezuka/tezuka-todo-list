import 'package:flutter/material.dart';
import 'package:todo_management/todo_view.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  String _text = '';

  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    '※そのユーザーは既に存在しています。',
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
                            title: 'TODO管理',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'ユーザー登録',
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
