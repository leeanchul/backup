import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/screens/CinemaOneScreen.dart';
import 'package:movie_flutter/screens/CustomNavigationBar.dart';
import 'package:movie_flutter/screens/Login_screen.dart';

class CinemaListscreen extends StatefulWidget {
  @override
  _CinemaListScreenState createState() => _CinemaListScreenState();
}

class _CinemaListScreenState extends State<CinemaListscreen> {
  final storage = FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> _cinema = [];
  bool _isLoading = true;
  String? token;
  final List<String> _cities = <String>[
    '서울',
    '경기',
    '인천',
    '강원',
    '대전충청',
    '대구',
    '부산울산',
    '경상',
    '광주전라제주'
  ];
  int _selectCity = 0;

  @override
  void initState() {
    super.initState();
    _getCinema();
  }

  Future<void> _getCinema() async {
    try {
      String? token = await storage.read(key: 'jwt');

      if (token == null) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => LoginScreen()),
        );
      }
      setState(() {
        _isLoading = true;
      });
      _dio.options.headers['Authorization'] = "Bearer $token";
      final response = await _dio.get(
        'http://localhost:9000/api/cinema/cinema/${_cities[_selectCity]}',
      );
      setState(() {
        _cinema = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
          CustomNavigationBar(currentPage: 'Cinema'), // NavigationBar 사용
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showDialog(
              CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32.0, // 각 항목의 높이를 32.0 픽셀로 설정
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _selectCity = selectedItem;
                    _getCinema();
                  });
                },
                children: List<Widget>.generate(_cities.length, (int index) {
                  return Center(
                    child: Text(
                      _cities[index],
                    ),
                  );
                }),
              ),
            ),
            child: Text(
              _cities[_selectCity],
              style: const TextStyle(
                fontSize: 22.0,
              ),
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 300, // ListView의 높이를 300픽셀로 설정
            child: _cinema.isEmpty
                ? Center(child: Text("없음"))
                : ListView.builder(
                    itemCount: _cinema.length,
                    itemBuilder: (context, index) {
                      final cinema = _cinema[index];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CupertinoListTile(
                              backgroundColor: CupertinoColors.systemBrown,
                              title: Text(cinema['spotName']),
                              subtitle: Text(cinema['area']),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => CinemaOneScreen(
                                      id: cinema['id'],
                                      spotName: cinema['spotName'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 5), // 각 항목 뒤에 빈 공간 추가
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
