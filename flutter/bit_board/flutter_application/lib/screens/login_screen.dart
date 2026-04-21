import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/screens/board_list_screen.dart';
import 'package:flutter_application/screens/register_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();
  final storage = FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _dio.post('http://localhost:8080/api/user/auth',
          data: {
            'username': _usernameController.text,
            'password': _passwordController.text
          });

      if (response.statusCode == 200) {
        if (response.data['result'] == 'success') {
          await storage.write(key: 'jwt', value: response.data['token']);
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => BoardListScreen(
                        pageNo: 1,
                      )));
        } else {
          _showCupertinoDialog();
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showCupertinoDialog() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('로그인 실패'),
              content: Text('로그인 정보를 다시 확인 해주세요!'),
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
        middle: Text('로그인'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoTextField(
            controller: _usernameController,
            placeholder: '아이디',
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: CupertinoColors.systemBrown,
                borderRadius: BorderRadius.circular(8)),
          ),
          SizedBox(
            height: 15,
          ),
          CupertinoTextField(
            controller: _passwordController,
            placeholder: '비밀번호',
            obscureText: true, //type password 설정
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: CupertinoColors.systemBrown,
                borderRadius: BorderRadius.circular(8)),
          ),
          SizedBox(
            height: 15,
          ),
          _isLoading
              ? CupertinoActivityIndicator()
              : CupertinoButton.filled(onPressed: _login, child: Text('로그인')),
          CupertinoButton.filled(
              onPressed: () {
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text('회원 가입'))
        ],
      ),
    );
  }
}
