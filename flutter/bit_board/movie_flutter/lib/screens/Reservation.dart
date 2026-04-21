import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/screens/CustomNavigationBar.dart';
import 'package:movie_flutter/screens/Login_screen.dart';
import 'package:movie_flutter/screens/SeatScreen.dart';

class Reservation extends StatefulWidget {
  final String timeItem;

  Reservation({required this.timeItem});

  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  final storage = FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> _shows = [];
  List<dynamic> _cinema = [];
  List<dynamic> _time = [];

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
  bool _isLoadingShows = true;
  bool _isLoadingCinemas = true;
  String? token;
  int cinemaId = 0;
  int movieId = 0;
  String movieTitle = '';
  String spotName = '';
  String selectTime = '';
  int selectId = 0;
  @override
  void initState() {
    super.initState();
    _getShows();
    _getCinemas();
    _gettime();
  }

  Future<void> _getShows() async {
    try {
      token = await storage.read(key: 'jwt');

      if (token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      setState(() {
        _isLoadingShows = true;
      });

      _dio.options.headers['Authorization'] = "Bearer $token";
      final response = await _dio.get('http://localhost:9000/api/show/showAll');

      setState(() {
        _shows = response.data;
        _isLoadingShows = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingShows = false;
      });
      print(e);
    }
  }

  Future<void> _getCinemas() async {
    try {
      token = await storage.read(key: 'jwt');

      if (token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      setState(() {
        _isLoadingCinemas = true;
      });

      _dio.options.headers['Authorization'] = "Bearer $token";
      final cinemaResponse = await _dio.get(
        'http://localhost:9000/api/cinema/cinema/${_cities[_selectCity]}',
      );

      setState(() {
        _cinema = cinemaResponse.data;
        _isLoadingCinemas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCinemas = false;
      });
      print(e);
    }
  }

  Future<void> _gettime() async {
    token = await storage.read(key: 'jwt');
    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    if (cinemaId != 0) {
      _dio.options.headers["Authorization"] = "Bearer $token";
      final roomsResponse = await _dio
          .get("http://localhost:9000/api/rooms/roomsAll/${cinemaId}");
      setState(() {
        _time = roomsResponse.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(currentPage: 'Reservation'),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: SafeArea(
          child: _isLoadingShows || _isLoadingCinemas
              ? Center(child: CupertinoActivityIndicator())
              : SingleChildScrollView(
                  // 화면에 맞게 스크롤할 수 있도록 감싸줌
                  child: Column(
                    children: [
                      // Row 안에 모든 리스트들을 쭉 나열할 때, 화면에 맞게 스크롤되도록 수정
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              itemCount: _shows.length,
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // 세로 스크롤 비활성화
                              itemBuilder: (context, index) {
                                final show = _shows[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: CupertinoButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        movieId = show['movieId'];
                                        movieTitle = show['title'];
                                      });
                                    },
                                    child: Text(
                                      '(${show['age']}) ${show['title']} ',
                                      style: (movieId == show['movieId'])
                                          ? TextStyle(
                                              color: CupertinoColors
                                                  .destructiveRed)
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          VerticalDivider(
                              width: 1.0, color: CupertinoColors.systemGrey),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              itemCount: _cities.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                  child: Container(
                                    width: 10,
                                    height: 40,
                                    child: CupertinoButton.filled(
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        setState(() {
                                          cinemaId = 0;
                                          _time.clear();
                                          _selectCity = index;
                                          _getCinemas();
                                        });
                                      },
                                      child: Text(
                                        _cities[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: (index == _selectCity)
                                              ? CupertinoColors.destructiveRed
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          VerticalDivider(
                              width: 1.0, color: CupertinoColors.systemGrey),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              itemCount: _cinema.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final cinema = _cinema[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: CupertinoButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        spotName = cinema['spotName'];
                                        cinemaId = cinema['id'];
                                        _gettime();
                                      });
                                    },
                                    child: Text(
                                      cinema['spotName'],
                                      style: (cinemaId == cinema['id'])
                                          ? TextStyle(
                                              color: CupertinoColors
                                                  .destructiveRed)
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          VerticalDivider(
                              width: 1.0, color: CupertinoColors.systemGrey),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _time.length,
                              itemBuilder: (context, index) {
                                final time = _time[index];

                                if (movieId == time['movieId']) {
                                  return CupertinoListTile(
                                    title:
                                        Text('${time['name']} ${time['id']}'),
                                    subtitle: Wrap(
                                      children:
                                          time['time'].map<Widget>((timeItem) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectTime = timeItem;
                                              selectId = time['id'];
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              color:
                                                  CupertinoColors.systemBrown,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Text(
                                              timeItem,
                                              style: timeItem == selectTime &&
                                                      selectId == time['id']
                                                  ? TextStyle(
                                                      fontSize: 24.0,
                                                      color: Colors.red)
                                                  : TextStyle(
                                                      fontSize: 24.0,
                                                      color: Colors.white),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // 하단 텍스트 추가
                      Text(
                        '선택한 영화: ${movieTitle}\n선택한 장소: ${spotName}\n선택한 시간: ${selectTime}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CupertinoButton.filled(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Seatscreen(
                                      movieTitle: movieTitle,
                                      movieId: movieId,
                                      spotName: spotName,
                                      selectTime: selectTime,
                                      selectId: selectId)));
                        },
                        child: Text('좌석 선택'),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
