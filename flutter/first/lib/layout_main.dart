import 'package:first/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '레이아웃 예제!',
      home: Scaffold(
          appBar: AppBar(
            title: Text('레이아웃'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 200,
                  color: Colors.deepOrangeAccent,
                  child: Text('주황색 컨테이너',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                SizedBox(height: 20, width: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 200,
                        color: Colors.deepPurpleAccent,
                        child: Text('보라색 컨테이너',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                    SizedBox(height: 20, width: 20),
                    Expanded(
                      child: Container(
                        height: 100,
                        color: Colors.blue,
                        child: Text('파란색 컨테s이너',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
