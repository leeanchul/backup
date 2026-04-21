import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/screens/CinemaListscreen.dart';
import 'package:movie_flutter/screens/Login_screen.dart';
import 'package:movie_flutter/screens/MovieListScreen.dart';
import 'package:movie_flutter/screens/MyPageScreen.dart'; // 내 정보 페이지 화면을 임포트
import 'package:movie_flutter/screens/Reservation.dart';

class CustomNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final String currentPage;

  CustomNavigationBar({required this.currentPage});
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  void _logout(BuildContext context) async {
    // Clear the JWT token from secure storage
    await _storage.delete(key: 'jwt');
    // Navigate to the Login screen after logout
    Navigator.pushReplacement(
        context, CupertinoPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(currentPage == 'Cinema'
          ? '극장'
          : currentPage == 'Movie'
              ? '영화'
              : currentPage == 'Myinfo'
                  ? '내 정보'
                  : currentPage == 'Reservation'
                      ? '예매'
                      : '예매'), // If page is Reservation, show '예매'
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: currentPage == 'Movie'
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MovieListScreen(pageNo: 1),
                      ),
                    );
                  },
            child: Text(
              "영화",
              style: TextStyle(
                color: currentPage == 'Movie'
                    ? CupertinoColors.systemYellow
                    : CupertinoColors.black,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: currentPage == 'Cinema'
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => CinemaListscreen(),
                      ),
                    );
                  },
            child: Text(
              "극장",
              style: TextStyle(
                color: currentPage == 'Cinema'
                    ? CupertinoColors.systemYellow
                    : CupertinoColors.black,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: currentPage == 'Reservation'
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Reservation(
                          timeItem: '',
                        ), // "예매" 페이지로 이동
                      ),
                    );
                  },
            child: Text(
              "예매",
              style: TextStyle(
                color: currentPage == 'Reservation'
                    ? CupertinoColors.systemYellow
                    : CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _logout(context), // Enable the logout button
            child: Text(
              "로그 아웃",
              style: TextStyle(
                  color: CupertinoColors.systemRed // Red color for logout
                  ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: currentPage == 'Myinfo'
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MyPageScreen(), // "내 정보" 페이지로 이동
                      ),
                    );
                  },
            child: Text(
              "내 정보",
              style: TextStyle(
                color: currentPage == 'Myinfo'
                    ? CupertinoColors.systemYellow
                    : CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(44.0);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return false;
  }
}
