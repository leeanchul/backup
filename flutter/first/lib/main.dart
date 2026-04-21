import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hello, World!!',
        home: Scaffold(
          appBar: AppBar(
            title: Text('헬로우 월드!!'),
          ),
          body: Center(
              child: Text('Hellow World',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 35))),
        ));
  }
}
