import 'package:first/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  List<String> items = List.generate(20, (index) => "Item $index");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListView 만들기',
      home: Scaffold(
          appBar: AppBar(
            title: Text('ListView 예제'),
          ),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                  leading: Icon(Icons.label), title: Text(items[index]));
            },
          )),
    );
  }
}
