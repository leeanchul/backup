import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  final Dio _dio = Dio();

  bool _isSubmitting = false;

  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String nickname = _nicknameController.text;

    if (username.isEmpty || password.isEmpty || nickname.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Response = await _dio
          .post("http://localhost:8080/api/user/register", data: {
        "username": username,
        "password": password,
        "nickname": nickname
      });

      if (Response.data['result'] == 'success') {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
      } else {
        _showCupertinoDialog(Response.data['message']);
      }
    } catch (e) {
      print(e);
    }
  }

  void _showCupertinoDialog(String message) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('회원가입 시루ㅐㅍ'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('회원가입'),
      ),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoTextField(
              controller: _usernameController,
              placeholder: "아이디",
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 7, 243, 211),
                  borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(
              height: 16,
            ),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: "비밀번호",
              obscureText: true, //type password 설정
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 7, 243, 211),
                  borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(
              height: 16,
            ),
            CupertinoTextField(
              controller: _nicknameController,
              placeholder: "닉네임",
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 7, 243, 211),
                  borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(
              height: 16,
            ),
            CupertinoButton.filled(
              onPressed: () {
                _register();
              },
              child: Icon(CupertinoIcons.add_circled_solid),
            )
          ],
        ),
      ),
    );
  }
}
