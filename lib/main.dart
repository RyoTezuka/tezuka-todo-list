import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_management/screen/login/login_screen_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TodoManagementApp());
}

class TodoManagementApp extends StatefulWidget {
  const TodoManagementApp({Key? key}) : super(key: key);

  @override
  _TodoManagementAppState createState() => _TodoManagementAppState();
}

class _TodoManagementAppState extends State<TodoManagementApp> {
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
