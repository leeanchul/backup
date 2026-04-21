import 'package:flutter/cupertino.dart';
import 'package:flutter_application/screens/login_screen.dart';

void main() {
  runApp(BoardApp());
}

class BoardApp extends StatelessWidget {
  const BoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: '게시판',
        theme: CupertinoThemeData(primaryColor: CupertinoColors.systemBlue),
        home: LoginScreen());
  }
}
