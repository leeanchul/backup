import 'package:flutter/cupertino.dart';
import 'package:movie_flutter/screens/Login_screen.dart';

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: '영화',
        theme: CupertinoThemeData(primaryColor: CupertinoColors.black),
        home: LoginScreen());
  }
}
