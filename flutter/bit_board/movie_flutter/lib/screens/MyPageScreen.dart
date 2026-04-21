import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/screens/CustomNavigationBar.dart';
import 'package:movie_flutter/screens/Login_screen.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final TextEditingController _newNickname = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _newPassword2 = TextEditingController();
  final TextEditingController _textReview = TextEditingController();
  dynamic? _Info;
  List<dynamic> _scope = [];
  bool _isSubmitting = false;
  bool _isUpdate = false;
  double? _rating;
  bool _isRole = false;
  List<dynamic> _review = [];
  dynamic? tiket;
  @override
  void initState() {
    super.initState();
    _getInfo();
  }

  // 정보 가져오기
  Future<void> _getInfo() async {
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }

    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get("http://localhost:9000/api/user/info");
      setState(() {
        _Info = response.data;
        _isSubmitting = true;
      });

      if (_Info != null && _Info['id'] != 0) {
        final scopeResponse = await _dio
            .get("http://localhost:9000/api/scope/scopeInfo/${_Info['id']}");

        setState(() {
          _scope = scopeResponse.data;
        });
      }

      if (_Info['role'] == 'ROLE_TEST') {
        final reviewResponse = await _dio
            .get("http://localhost:9000/api/review/userReview/${_Info['id']}");

        setState(() {
          _review = reviewResponse.data;
        });
      }

      final tiketResponse = await _dio.post(
          "http://localhost:9000/api/seat/tiketInfo",
          data: {"userId": _Info['id']});
      setState(() {
        tiket = tiketResponse.data;
      });
      print(tiketResponse);
    } catch (e) {
      print(e);
    }
  }

  // 별점 수정
  Future<void> _updateScore(int id) async {
    if (_rating == null) {
      setState(() {
        _isUpdate = false;
      });
      return;
    }
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
    await _dio.post(
      "http://localhost:9000/api/scope/scoreUpdate",
      data: {"id": id, "score": _rating},
    );
    setState(() {
      _isUpdate = false;
      _getInfo();
    });
  }

  // 별점 수정 모달
  void _showScope(int id) async {
    setState(() {
      _isUpdate = true;
    });
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
            title: Text('별점 남기기'),
            content: Row(
              children: [
                RatingBar.builder(
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                )
              ],
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text('확인'),
                  onPressed: () async {
                    _updateScore(id);
                    Navigator.of(context).pop(); // 별점 다이얼로그 닫기
                  }),
              CupertinoDialogAction(
                  child: Text('닫기'),
                  onPressed: () {
                    setState(() {
                      _isUpdate = false;
                    });
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  })
            ]);
      },
    );
  }

  //별점/리뷰 삭제
  Future<void> _delete(int id) async {
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
    if (id != 0 && _isRole) {
      await _dio.get("http://localhost:9000/api/review/delete/$id");
    } else if (id != 0) {
      await _dio.get("http://localhost:9000/api/scope/delete/$id");
    }
    setState(() {
      _isUpdate = false;
      _getInfo();
    });
  }

  // 별점/리뷰 삭제 모달
  void _showDelete(int id) {
    setState(() {
      _isUpdate = true;
    });
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('삭제'),
              content: Text("$id 삭제 하겠습니까?."),
              actions: [
                CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () {
                      _delete(id);
                      Navigator.of(context).pop();
                    }),
                CupertinoDialogAction(
                    child: Text('취소'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isUpdate = false;
                      });
                    })
              ]);
        });
  }

  // 닉네임 수정
  Future<int?> _updateInfo(int? id) async {
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
    try {
      final response = await _dio.post("http://localhost:9000/api/user/update",
          data: {"id": id, "newNickname": _newNickname.text});

      _newNickname.clear(); // clear()로 수정

      return response.statusCode; // response.statusCode를 반환
    } catch (e) {
      return null;
    }
  }

  // 닉네임 모달
  void _showInfo(int id) {
    _newNickname.clear;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('닉네임 수정'),
              content: CupertinoTextField(
                controller: _newNickname,
                placeholder: "new 닉네임",
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(8)),
              ),
              actions: [
                CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () async {
                      final statusCode = await _updateInfo(id);
                      if (statusCode == 200) {
                        Navigator.of(context).pop();
                        _showCupertinoDialog("변경 성공!", "변경 되었습니다.");
                      } else {
                        Navigator.of(context).pop();
                        _showCupertinoDialog("변경 실패!", "중복된 닉네임");
                      }
                    }),
                CupertinoDialogAction(
                    child: Text('취소'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // 비번 변경
  Future<int?> _updatePwd() async {
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }

    if (_password.text == '' || _newPassword.text == '') {
      return null;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _dio
          .post("http://localhost:9000/api/user/updatePwd", data: {
        "id": _Info['id'],
        "password": _password.text,
        "newPassword": _newPassword.text
      });
      return response.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  // 비번 모달
  void _showPwd() async {
    _newNickname.clear();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: Text('비밀번호 수정'),
                content: Column(
                  children: [
                    CupertinoTextField(
                      controller: _password,
                      placeholder: "현재 비밀번호",
                      obscureText: true,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CupertinoTextField(
                      controller: _newPassword,
                      obscureText: true,
                      placeholder: "new 비밀번호",
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CupertinoTextField(
                      controller: _newPassword2,
                      placeholder: "new 비밀번호 확인",
                      obscureText: true,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                      child: Text('확인'),
                      onPressed: () async {
                        if (_password.text == '') {
                          _showCupertinoDialog("오류", "패스워드가 입력되지 않았습니다.");
                        } else if (_newPassword.text != _newPassword2.text) {
                          _showCupertinoDialog("오류", "새 비밀번호가 일치하지 않습니다.");
                        } else if (_password.text != '' &&
                            _newPassword.text != '') {
                          // 비밀번호 업데이트 로직을 여기에 추가
                          Navigator.of(context).pop();
                          final statusCode = await _updatePwd();

                          if (statusCode == 200) {
                            // 비밀번호 변경 성공
                            _showCupertinoDialog("성공", '로그아웃합니다.');
                          } else {
                            // 변경 실패
                            _showCupertinoDialog("실패", "비밀번호 변경에 실패했습니다.");
                          }
                        }
                      }),
                  CupertinoDialogAction(
                      child: Text('취소'),
                      onPressed: () {
                        _password.clear();
                        _newPassword.clear();
                        _newPassword2.clear();
                        Navigator.of(context).pop();
                      })
                ],
              );
            },
          );
        });
  }

  // 리뷰 수정
  Future<void> _updateReview(int id) async {
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
    if (_textReview.text != '') {
      await _dio.post("http://localhost:9000/api/review/update",
          data: {"id": id, "review": _textReview.text});
    }
    setState(() {
      _getInfo();
    });
  }

  // 리뷰 모달
  void _showReview(int id) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('댓글 수정'),
              content: CupertinoTextField(
                controller: _textReview,
                placeholder: '변경할 리뷰',
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen,
                    borderRadius: BorderRadius.circular(8)),
              ),
              actions: [
                CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () {
                      _updateReview(id);
                      Navigator.of(context).pop();
                    })
              ]);
        });
    _newNickname.clear();
    _password.clear();
    _newPassword.clear();
    _newPassword2.clear();
    _review.clear();
    setState(() {
      _getInfo();
    });
  }

  // 예약 정보
  void _showTiket() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('예약 티켓 정보'),
              content: Column(children: [
                if (tiket == null) Text('예약 정보 없음'), // ✅ 중괄호 제거

                Text("------------------"),
                Text("| ${tiket['movieTitle']}  |"),
                Text("| 좌석: ${tiket['selectedSeats']} |"),
                Text("| 영화시간: ${tiket['selectTime']} |"),

                if (tiket['generalCount'] != 0)
                  Text("일반 관람객: ${tiket['generalCount']}명"),
                if (tiket['teenagerCount'] != 0)
                  Text("청소년 관람객: ${tiket['teenagerCount']}명"),
              ]),
              actions: [
                CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // 다이아로그용
  void _showCupertinoDialog(String title, String content) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (content == '로그아웃합니다.') {
                        _storage.delete(key: 'jwt');
                        // Navigate to the Login screen after logout
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => LoginScreen()));
                      }
                    })
              ]);
        });
    _newNickname.clear();
    _password.clear();
    _newPassword.clear();
    _newPassword2.clear();
    setState(() {
      _getInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(currentPage: 'Myinfo'),
      child: _isSubmitting
          ? Column(
              children: [
                SizedBox(height: 100),
                Text("아이디: ${_Info['username']}"),
                SizedBox(height: 10),
                Text("이름: ${_Info['nickname']}"),
                SizedBox(height: 10),
                _Info['role'] == 'ROLE_TEST'
                    ? Text('등급:평론가')
                    : Text("등급: 일반사용자"),
                SizedBox(height: 10),
                CupertinoButton.filled(
                    onPressed: () {
                      _showInfo(_Info['id']);
                    },
                    child: Text('닉네임 수정')),
                SizedBox(
                  height: 10,
                ),
                CupertinoButton.filled(
                    onPressed: () {
                      _showPwd();
                    },
                    child: Text('비밀번호 수정')),
                SizedBox(
                  height: 20,
                ),
                CupertinoButton.filled(
                    child: Text('티켓 정보'),
                    onPressed: () {
                      _showTiket();
                    }),
                SizedBox(
                  height: 10,
                ),
                _Info['role'] == 'ROLE_TEST'
                    ? Column(
                        children: [
                          CupertinoButton.filled(
                            onPressed: () {
                              setState(() {
                                _isRole = !_isRole;
                              });
                            },
                            child: _isRole ? Text('별점 보기') : Text('댓글 보기'),
                          ),
                          _isRole
                              ? Text('-----댓글 기록-----')
                              : Text('-----별점 기록-----'),
                        ],
                      )
                    : Text('-----별점 기록-----'),
                _isRole
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _review.length,
                          itemBuilder: (context, index) {
                            final review = _review[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                color:
                                    CupertinoColors.systemGreen, // 원하는 색상으로 변경
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("영화 제목: ${review['title']}"),
                                    SizedBox(height: 5),
                                    Text("댓글: ${review['review']}",
                                        style: TextStyle(
                                            fontSize: 30 // 원하는 글자 크기로 설정하세요
                                            )),
                                    SizedBox(height: 5),
                                    Text("닉네임: ${review['nickname']}"),
                                    SizedBox(height: 5),
                                    Text("날짜: ${review['entryDate']}"),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        CupertinoButton.filled(
                                          onPressed: () {
                                            _showReview(review['id']);
                                          },
                                          child: Text('수정'),
                                        ),
                                        SizedBox(width: 10),
                                        CupertinoButton.filled(
                                          onPressed: () {
                                            _showDelete(review['id']);
                                          },
                                          child: Text('삭제'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _scope.length,
                          itemBuilder: (context, index) {
                            final scope = _scope[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                color:
                                    CupertinoColors.systemOrange, // 원하는 색상으로 변경
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("영화 제목: ${scope['title']}"),
                                    SizedBox(height: 5),
                                    Text("점수: ${scope['score']}",
                                        style: TextStyle(
                                            fontSize: 30 // 원하는 글자 크기로 설정하세요
                                            )),
                                    SizedBox(height: 5),
                                    Text("날짜: ${scope['entryDate']}"),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        CupertinoButton.filled(
                                          onPressed: () {
                                            _isUpdate
                                                ? null
                                                : _showScope(scope['id']);
                                          },
                                          child: Text('수정'),
                                        ),
                                        SizedBox(width: 10),
                                        CupertinoButton.filled(
                                          onPressed: () {
                                            _isUpdate
                                                ? null
                                                : _showDelete(scope['id']);
                                          },
                                          child: Text('삭제'),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            )
          : Center(child: CupertinoActivityIndicator()),
    );
  }
}
