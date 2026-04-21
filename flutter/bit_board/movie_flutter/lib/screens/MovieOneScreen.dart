import 'dart:typed_data'; // Uint8List 사용
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_flutter/screens/Login_screen.dart';
import 'package:movie_flutter/screens/MovieListScreen.dart';

class MovieOneScreen extends StatefulWidget {
  final int movieId;
  final int pageNo;

  MovieOneScreen({required this.movieId, required this.pageNo});

  @override
  _MovieOneScreenState createState() => _MovieOneScreenState();
}

class _MovieOneScreenState extends State<MovieOneScreen> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final TextEditingController _reviewController = TextEditingController();
  dynamic? _movie;
  String? _token;
  Uint8List? _imageBytes; // 이미지를 저장할 변수
  double? _rating;
  dynamic? _scope;
  dynamic? _review;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _getMovie();
  }

  Future<void> _writeReviw() async {
    setState(() {
      _isSubmitting = true;
    });
    String? token = await _storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }

    if (_reviewController.text == '') {
      _showCupertinoDialog("리뷰 실패", "리뷰를 입력해주세요");
      return;
    }

    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
          "http://localhost:9000/api/review/reviewInsert",
          data: {"movieId": widget.movieId, "review": _reviewController.text});
      if (response.statusCode == 200) {
        _showCupertinoDialog("성공!", "리뷰 작성 완료!");
      }
    } catch (e) {
      _showCupertinoDialog("실패!", "이미 리뷰 작성 OR 평론가가 아닙니다.!");
    }
  }

  // 영화 데이터와 이미지 데이터를 받아오는 함수
  Future<void> _getMovie() async {
    try {
      _token = await _storage.read(key: 'jwt');
      if (_token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      _dio.options.headers["Authorization"] = "Bearer $_token";
      final response = await _dio
          .get("http://localhost:9000/api/movie/movieOne/${widget.movieId}");
      // null 체크를 추가합니다.
      if (response.data != null) {
        setState(() {
          _movie = response.data;
        });

        // 영화 이미지 불러오기
        if (_movie != null && _movie['filePath'] != null) {
          final imageResponse = await _dio.get(
            "http://localhost:9000/api/movie/upload/${_movie['filePath']}",
            options: Options(responseType: ResponseType.bytes),
          );
          setState(() {
            _imageBytes = imageResponse.data; // 받아온 이미지를 _imageBytes에 저장
          });
        }

        if (_movie != null) {
          _dio.options.headers["Authorization"] = "Bearer $_token";
          final scoreResponse = await _dio.post(
              "http://localhost:9000/api/scope/scopeAvg",
              data: {"movieId": widget.movieId});

          setState(() {
            _scope = scoreResponse.data;
          });
        }

        final reviewResponse = await _dio.get(
            "http://localhost:9000/api/review/reviewAll/${widget.movieId}");
        setState(() {
          _review = reviewResponse.data;
        });
      } else {
        print("Movie data is null");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int?> _insertScore(double? rating) async {
    if (rating == null || rating < 1) {
      _showCupertinoDialog("별점 입력 오류", "다시 확인 해주세요!");
      return null; // 별점이 없으면 실행하지 않도록
    }

    try {
      _token = await _storage.read(key: 'jwt');
      if (_token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return null;
      }

      final response = await _dio.post(
        "http://localhost:9000/api/scope/scoreInsert",
        data: {"movieId": widget.movieId, "score": _rating},
      );

      return response.statusCode; // statusCode 반환
    } catch (e) {
      print(e);
      return null; // 예외가 발생한 경우에도 null 반환
    }
  }

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
                    })
              ]);
        });
    _reviewController.clear();
    setState(() {
      _rating = 0;
      _isSubmitting = false;
    });
  }

  void _showScope() async {
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
                  Navigator.of(context).pop(); // 별점 다이얼로그 닫기
                  final statusCode = await _insertScore(_rating); // API 호출

                  if (statusCode == 200) {
                    setState(() {
                      _getMovie(); // 데이터를 다시 불러옵니다.
                    });
                    // 성공 다이얼로그
                    _showCupertinoDialog("별점 입력 완료", "별점이 성공적으로 입력되었습니다.");
                  } else {
                    // 실패 다이얼로그
                    _showCupertinoDialog("별점 입력 오류", "이미 별점을 남겼습니다.!");
                  }
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_movie?["title"] ?? "불러오는 중..."),
        trailing: CupertinoButton.filled(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => MovieListScreen(pageNo: widget.pageNo),
              ),
            );
          },
          child: Icon(CupertinoIcons.backward),
        ),
      ),
      child: _movie == null
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이미지가 존재하면 출력
                  _imageBytes != null
                      ? Image.memory(
                          _imageBytes!, width: 500, // 원하는 너비
                          height: 300,
                        )
                      : Image.network(
                          "data:image/png;base64,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",
                          width: 500,
                          height: 300,
                        ), // 이미지가 로딩될 때까지 표시
                  SizedBox(height: 20),
                  Text("제목 : ${_movie?["title"] ?? "정보 없음"}"),
                  Text("글번호: ${_movie?["id"] ?? "정보 없음"}"),
                  Text("감독 : ${_movie?["director"] ?? "정보 없음"}"),
                  Text("test${_movie?["role"]}"),
                  Text(
                    "별점 : ${_scope?["maxAvg"] ?? 0} (인원 : ${_scope?["count"] ?? 0})",
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CupertinoButton.filled(
                    onPressed: () {
                      _showScope(); // 별점 다이얼로그 호출
                    },
                    child: Text('별점'),
                  ),
                  SizedBox(
                    height: 20,
                  ), // 리뷰 입력 필드와 버튼을 Row로 감싸서 한 줄에 배치
                  _movie!["role"] != "ROLE_USER"
                      ? Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField(
                                controller: _reviewController,
                                placeholder: '리뷰',
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: CupertinoColors.systemTeal,
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            CupertinoButton.filled(
                              onPressed: _isSubmitting ? null : _writeReviw,
                              child: Text('작성'),
                            ),
                          ],
                        )
                      : Text(''),
                  SizedBox(
                    height: 30,
                  ),
                  // _review가 null이거나 빈 리스트일 때 처리
                  _review == null || _review.isEmpty
                      ? Text("리뷰가 없습니다.") // 리뷰가 없으면 이 메시지를 표시
                      : Container(
                          // 리뷰 리스트를 고정된 크기로 처리
                          height: 200, // 원하는 높이로 설정
                          child: ListView.builder(
                            itemCount: _review.length,
                            itemBuilder: (context, index) {
                              final review = _review[index];
                              return CupertinoListTile(
                                title: Text(review['review']),
                                subtitle: Text(
                                    "${review['nickname']} - ${review['entryDate']}"),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
