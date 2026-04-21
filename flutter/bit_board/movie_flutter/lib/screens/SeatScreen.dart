import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/object/ReservationInfo.dart';
import 'package:movie_flutter/screens/CustomNavigationBar.dart';
import 'package:movie_flutter/screens/Login_screen.dart';
import 'package:movie_flutter/screens/PayScreen.dart';

class Seatscreen extends StatefulWidget {
  final String movieTitle;
  final int movieId;
  final String spotName;
  final String selectTime;
  final int selectId;
  Seatscreen(
      {required this.movieTitle,
      required this.movieId,
      required this.spotName,
      required this.selectTime,
      required this.selectId});

  @override
  _SeatscreenState createState() => _SeatscreenState();
}

class _SeatscreenState extends State<Seatscreen> {
  final storage = FlutterSecureStorage();
  final Dio _dio = Dio();
  String? token;
  int? _General = 0; // 어른의 기본 선택값
  int? _Teenager = 0; // 청소년의 기본 선택값
  int? _result = 0; // 결과값을 이용하여 버튼 클릭 여부를 결정
  // 선택할 사람 수
  List<int> generalOptions = [0, 1, 2, 3, 4, 5];
  //좌석 로딩용
  bool isReady = true;

  //좌석 열
  List<dynamic> _row = [];
  //좌석 행
  int _maxCol = 0;

  // 좌석에 상태
  List<List<bool>> _isReserved = [];

  // 색상 상태 저장
  List<List<bool>> _buttonSelected =
      List.generate(10, (_) => List.generate(10, (_) => false));

  // 좌석 정보 리스트
  List<String> selectedSeats = [];

  // 선택된 총 인원 수 (어른 + 청소년)
  int selectedPeople = 0;

  // 좌석 상태 초기화
  void resetSeats() {
    selectedSeats.clear();
    _buttonSelected = List.generate(10, (_) => List.generate(10, (_) => false));
  }

  @override
  void initState() {
    super.initState();
    _getTest();
  }

  // 인원수를 변경할 수 있는지 체크하는 함수
  bool canChangePeople(int? newGeneral, int? newTeenager) {
    // 선택된 좌석이 현재 인원수보다 많으면 라디오버튼을 변경할 수 없음
    return selectedSeats.length <= (newGeneral ?? 0) + (newTeenager ?? 0);
  }

  Future<void> _getTest() async {
    token = await storage.read(key: 'jwt');

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    _dio.options.headers['Authorization'] = "Bearer $token";
    final response = await _dio.get(
      'http://localhost:9000/api/seat/seatOne/${widget.selectId}/${widget.selectTime}',
    );

    setState(() {
      _row = response.data['rows'];
      _maxCol = response.data['maxCol'];
      // 'isReserved'가 List<dynamic>로 반환되기 때문에,
      // 이를 List<List<bool>>로 변환
      _isReserved = List<List<bool>>.from(response.data['isReserved']
          .map((row) => List<bool>.from(row.map((e) => e as bool))));
      isReady = false;
    });
  }

  void _showCupertinoDialog() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('선택 불가'),
              content: Text('현재 선택된 좌석 수가 인원 수보다 많습니다. 좌석을 해제한 후 변경해주세요.'),
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
        navigationBar: CustomNavigationBar(currentPage: 'Reservation'),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "어른" 섹션
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('어른'),
                    SizedBox(width: 30),
                    ...generalOptions.map((value) {
                      return Row(
                        children: [
                          Text('$value 명'),
                          CupertinoRadio<int>(
                            value: value,
                            groupValue: _General,
                            onChanged: (newValue) {
                              // 새로운 어른 인원으로 변경이 가능한지 체크
                              if (canChangePeople(newValue, _Teenager)) {
                                setState(() {
                                  _General = newValue;
                                  _result = newValue; // result 값 업데이트
                                  selectedPeople = (_General ?? 0) +
                                      (_Teenager ?? 0); // 총 선택된 인원수 갱신
                                });
                              } else {
                                // 라디오 버튼 변경 불가
                                _showCupertinoDialog();
                              }
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 20),

                // "청소년" 섹션
                Row(
                  children: [
                    Text('청소년'),
                    SizedBox(width: 30),
                    ...generalOptions.map((value) {
                      return Row(
                        children: [
                          Text('$value 명'),
                          CupertinoRadio<int>(
                            value: value,
                            groupValue: _Teenager,
                            onChanged: (newValue) {
                              // 새로운 청소년 인원으로 변경이 가능한지 체크
                              if (canChangePeople(_General, newValue)) {
                                setState(() {
                                  _Teenager = newValue;
                                  _result = newValue; // result 값 업데이트
                                  selectedPeople = (_General ?? 0) +
                                      (_Teenager ?? 0); // 총 선택된 인원수 갱신
                                });
                              } else {
                                // 라디오 버튼 변경 불가
                                _showCupertinoDialog();
                              }
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 20),

                // 스크린 표시
                Text(
                    '------------------------------- 스 크 린 -------------------------------'),
                SizedBox(height: 30),

                // 좌석 버튼
                isReady
                    ? CupertinoActivityIndicator()
                    : isReady
                        ? CupertinoActivityIndicator()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: 10,
                              itemBuilder: (context, i) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      _row[i],
                                      style: TextStyle(
                                          color: CupertinoColors.systemPink),
                                    ),
                                    SizedBox(width: 10),
                                    for (int j = 1; j < _maxCol; j++)
                                      CupertinoButton(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          color: _buttonSelected[i][j - 1]
                                              ? CupertinoColors.activeOrange
                                              : CupertinoColors.systemGrey,
                                          onPressed: _isReserved[i]
                                                  [j - 1] // 예약된 좌석 체크
                                              ? null // 예약된 좌석은 클릭할 수 없도록 설정
                                              : () {
                                                  String seat = '${_row[i]}$j';
                                                  if (_buttonSelected[i]
                                                      [j - 1]) {
                                                    // 좌석을 취소할 경우
                                                    setState(() {
                                                      selectedSeats.remove(
                                                          seat); // 좌석 취소
                                                      _buttonSelected[i]
                                                              [j - 1] =
                                                          false; // 색상 회색으로 변경
                                                    });
                                                  } else if (selectedSeats
                                                          .length <
                                                      selectedPeople) {
                                                    // 선택 가능한 좌석 수가 남아있을 때만 선택
                                                    setState(() {
                                                      selectedSeats
                                                          .add(seat); // 좌석 선택
                                                      _buttonSelected[i]
                                                              [j - 1] =
                                                          true; // 색상 변경
                                                    });
                                                  } else {
                                                    _showCupertinoDialog();
                                                  }
                                                },
                                          child: Text('$j')),
                                  ],
                                );
                              },
                            ),
                          ),

                Center(
                  child: CupertinoButton.filled(
                      child: Text('예매하기'),
                      onPressed: () {
                        if (selectedSeats.isNotEmpty) {
                          final reservationInfo = ReservationInfo(
                            roomsId: widget.selectId,
                            movieTitle: widget.movieTitle,
                            movieId: widget.movieId,
                            spotName: widget.spotName,
                            selectTime: widget.selectTime,
                            selectedSeats: selectedSeats,
                            generalCount: _General ?? 0,
                            teenagerCount: _Teenager ?? 0,
                          );
                          Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => Payscreen(
                                  reservationInfo: reservationInfo,
                                ),
                              ));
                        }
                      }),
                ),
                SizedBox(
                  height: 30,
                ),

                Text(
                  '선택한 영화: ${widget.movieTitle}\n선택한 장소: ${widget.spotName}\n선택한 시간: ${widget.selectTime}\n선택한 자리: ${selectedSeats},\n 성인: ${_General} 청소년:${_Teenager}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ));
  }
}
