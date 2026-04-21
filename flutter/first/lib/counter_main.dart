import 'package:first/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: '카운터', home: CounterPage());
  }
}

class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _decreaseCounter() {
    setState(() {
      _counter--;
    });
  }

  void _increaseCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('카운터 앱',
              style: TextStyle(
                  color: Colors.cyanAccent,
                  backgroundColor: Colors.deepPurpleAccent,
                  fontSize: 48))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '버튼을 누른 횟수',
              style: TextStyle(color: Colors.greenAccent, fontSize: 24),
            ),
            Text('$_counter',
                style: TextStyle(color: Colors.redAccent, fontSize: 24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decreaseCounter,
                  tooltip: '-1 증가하기',
                  child: Icon(Icons.remove),
                ),
                SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  onPressed: _resetCounter,
                  tooltip: '0',
                  child: Icon(Icons.restart_alt),
                ),
                SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  onPressed: _increaseCounter,
                  tooltip: '1 증가하기',
                  child: Icon(Icons.add),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
