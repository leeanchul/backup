import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: '폼예제', home: FormPage());
  }
}

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _test = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('입력된 이름'),
                content:
                    Text('이름:' + _name + ' 주소:' + _test), // _name 변수를 문자열로 표시
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('확인'))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('폼 예제2')),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: '이름'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '주소'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '주소 입력하세요';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _test = value!;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: _submit, child: Text('입력하기'))
                  ],
                ))));
  }
}
