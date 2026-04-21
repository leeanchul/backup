import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/object/ReservationInfo.dart';
import 'package:movie_flutter/screens/Login_screen.dart';
import 'package:movie_flutter/screens/MyPageScreen.dart';
import 'package:movie_flutter/screens/Reservation.dart';

class Payscreen extends StatefulWidget {
  final ReservationInfo reservationInfo;

  Payscreen({required this.reservationInfo});

  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<Payscreen> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _token;
  String filePath = '';

  @override
  void initState() {
    super.initState();
    _getInfo();
  }

  Future<Uint8List?> _getTest(String? filePath) async {
    if (filePath == null) {
      return null;
    }
    final imageResponse = await _dio.get(
      "http://localhost:9000/api/movie/upload/$filePath",
      options: Options(responseType: ResponseType.bytes),
    );
    return imageResponse.data;
  }

  Future<void> _putpay() async {
    _dio.options.headers["Authorization"] = "Bearer $_token";
    final Response = await _dio.post(
      "http://localhost:9000/api/seat/tiket",
      data: {
        "movieTitle": widget.reservationInfo.movieTitle,
        "movieId": widget.reservationInfo.movieId,
        "spotName": widget.reservationInfo.spotName,
        "selectTime": widget.reservationInfo.selectTime,
        "selectedSeats": widget.reservationInfo.selectedSeats,
        "roomsId": widget.reservationInfo.roomsId,
        "generalCount": widget.reservationInfo.generalCount,
        "teenagerCount": widget.reservationInfo.teenagerCount,
      },
    );

    print(Response.data);
  }

  Future<void> _getInfo() async {
    _token = await _storage.read(key: 'jwt');
    if (_token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    _dio.options.headers["Authorization"] = "Bearer $_token";
    final response = await _dio.get(
        "http://localhost:9000/api/movie/movieOne/${widget.reservationInfo.movieId}");

    // 파일 경로 가져오기
    setState(() {
      filePath = response.data['filePath'];
    });
  }

  void _showCupertinoDialog() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('결제 화면'),
              content: Text('계좌 이체 해주세요 ㅎㅎ'),
              actions: [
                CupertinoDialogAction(
                    child: Text('결제완료!'),
                    onPressed: () {
                      _putpay();
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => Reservation(
                                    timeItem: '',
                                  )));
                    })
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('결제 화면'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FutureBuilder로 비동기 처리하여 이미지를 로드
              FutureBuilder<Uint8List?>(
                future: _getTest(filePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // 데이터 로딩 중일 때 로딩 인디케이터 표시
                    return CupertinoActivityIndicator();
                  } else if (snapshot.hasError) {
                    // 에러가 있을 경우 에러 메시지 표시
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    // 데이터가 있을 경우 이미지 표시 (크기 조정)
                    return Image.memory(
                      snapshot.data!,
                      width: 300, // 가로 크기 300
                      height: 300, // 세로 크기 300
                    );
                  } else {
                    return Text('이미지가 없습니다.');
                  }
                },
              ),
              Text('영화 정보: ${widget.reservationInfo.movieTitle}'),
              Text('상영 장소: ${widget.reservationInfo.spotName}'),
              Text('영화 시간: ${widget.reservationInfo.selectTime}'),

              // 선택된 좌석을 텍스트로 출력
              Text(
                '선택된 좌석:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // 선택된 좌석 리스트를 텍스트로 출력
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.reservationInfo.selectedSeats.map((seat) {
                  return Text(
                    seat,
                    style: TextStyle(fontSize: 18),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // 일반 사용자와 청소년 사용자 수 출력
              Text(
                '일반 사용자: ${widget.reservationInfo.generalCount}명',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '청소년 사용자: ${widget.reservationInfo.teenagerCount}명',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CupertinoButton.filled(
                    onPressed: () {
                      _showCupertinoDialog();
                    },
                    child: Text('결제'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CupertinoButton.filled(
                      child: Text('취소'),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => Reservation(
                                    timeItem:
                                        widget.reservationInfo.selectTime)));
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
