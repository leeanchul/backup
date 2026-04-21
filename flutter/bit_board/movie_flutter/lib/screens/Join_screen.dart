import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:movie_flutter/screens/Login_screen.dart';

class JoinScreen extends StatefulWidget {
  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _isSubmitting = false;
  final Dio _dio = Dio();

  Future<void> _Join() async {
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
      final Response = await _dio.post(
        "http://localhost:9000/api/user/register",
        data: {
          "username": username,
          "password": password,
          "nickname": nickname,
        },
      );

      if (Response.data['result'] == 'success') {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showCupertinoDialog(Response.data['message']);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showCupertinoDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('회원가입 실패'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            Text(
              '회원가입',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CupertinoTextField(
              controller: _usernameController,
              placeholder: "아이디",
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: "비밀번호",
              obscureText: true,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _nicknameController,
              placeholder: "닉네임",
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton.filled(
                  onPressed: _Join,
                  child:
                      _isSubmitting ? CupertinoActivityIndicator() : Text('가입'),
                ),
                CupertinoButton.filled(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('취소'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
