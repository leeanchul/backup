import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/screens/Join_screen.dart';
import 'package:movie_flutter/screens/MovieListScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final Dio _dio = Dio();
  final storage = FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.post('http://localhost:9000/api/user/auth',
          data: {'username': _username.text, 'password': _password.text});

      if (response.statusCode == 200) {
        await storage.write(key: 'jwt', value: response.data);
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (context) => MovieListScreen(pageNo: 1)));
      } else {
        _showCupertinoDialog();
      }
    } catch (e) {
      _showCupertinoDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 로그인 실패시
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
    _username.clear();
    _password.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('로그인'),
      ),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '로그인',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CupertinoTextField(
              controller: _username,
              placeholder: '아이디',
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            CupertinoTextField(
              controller: _password,
              obscureText: true,
              placeholder: '비밀번호',
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _isLoading
                    ? CupertinoActivityIndicator()
                    : CupertinoButton.filled(
                        onPressed: _login,
                        child: Text('로그인'),
                      ),
                CupertinoButton.filled(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => JoinScreen()),
                    );
                  },
                  child: Text('회원 가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
