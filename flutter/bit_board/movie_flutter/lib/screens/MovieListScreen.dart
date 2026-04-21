import 'dart:typed_data';
import 'dart:ui_web';

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:movie_flutter/screens/CustomNavigationBar.dart';
import 'package:movie_flutter/screens/Login_screen.dart';
import 'package:movie_flutter/screens/MovieOneScreen.dart';

class MovieListScreen extends StatefulWidget {
  final int pageNo;
  MovieListScreen({required this.pageNo});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final storage = FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> _movies = [];
  bool _isLoading = true;
  String? token;
  Uint8List? _imageBytes;

  int _currentPage = 1;
  int _startPage = 1;
  int _endPage = 5;
  int _maxPage = 5;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.pageNo;
    _getMovies();
  }

  Future<void> _getMovies() async {
    try {
      String? token = await storage.read(key: 'jwt');

      if (token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
      }

      _dio.options.headers['Authorization'] = "Bearer $token";
      await _getMoviesByPageNo(_currentPage);
    } catch (e) {
      print(e);
    }
  }

  void _changePage(int pageNo) {
    if (pageNo >= 1 && pageNo <= _maxPage) {
      _getMoviesByPageNo(pageNo);
    }
  }

  Future<void> _getMoviesByPageNo(int pageNo) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await _dio.get('http://localhost:9000/api/movie/movieAll/$pageNo');
      setState(() {
        _movies = response.data['content'];
        _startPage = response.data['startPage'];
        _endPage = response.data['endPage'];
        _currentPage = response.data['currentPage'];
        _maxPage = response.data['maxPage'];
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Uint8List?> _getTest(String? filePath) async {
    if (filePath == null) {
      return null;
    }
    // 영화 이미지 불러오기
    final imageResponse = await _dio.get(
      "http://localhost:9000/api/movie/upload/$filePath",
      options: Options(responseType: ResponseType.bytes),
    );

    return imageResponse.data;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(currentPage: 'Movie'),
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => MovieOneScreen(
                            movieId: movie['id'],
                            pageNo: _currentPage,
                          ),
                        ),
                      );
                    },
                    child: Container(
                        color: CupertinoColors.systemTeal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FutureBuilder(
                              future: _getTest(movie['filePath']),
                              builder: (context, test) {
                                if (test.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('이미지 로딩중');
                                } else if (movie['filePath'] == null) {
                                  return Image.network(
                                    "data:image/png;base64,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",
                                    width: 120,
                                    height: 120,
                                  );
                                } else if (test.hasError) {
                                  return Text('이미지 오류');
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120, // 원하는 너비 설정
                                        height: 120, // 원하는 높이 설정
                                        child: Image.memory(
                                          test.data!,
                                          fit: BoxFit.cover, // 이미지 크기 조정 방법 설정
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ), // 아이콘 대신 이미지 사용
                            SizedBox(width: 10), // 간격 조정
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(movie['title'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Text(
                                  "${movie['director']} - ${movie['relaseDate']}",
                                  style: TextStyle(
                                      color: CupertinoColors.systemGrey),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: () => _changePage(1),
                  child: Icon(
                    CupertinoIcons.left_chevron,
                  ),
                ),
                for (int i = _startPage; i <= _endPage; i++)
                  CupertinoButton(
                    onPressed: () => _changePage(i),
                    child: Text(
                      "$i",
                      style: TextStyle(
                          fontWeight: _currentPage == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _currentPage == i
                              ? CupertinoColors.destructiveRed
                              : CupertinoColors.activeBlue),
                    ),
                  ),
                CupertinoButton(
                    onPressed: () => _changePage(_maxPage),
                    child: Icon(
                      CupertinoIcons.right_chevron,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
