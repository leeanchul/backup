import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/screens/board_list_screen.dart';
import 'package:flutter_application/screens/board_update_screen.dart';
import 'package:flutter_application/screens/login_screen.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_html/flutter_html.dart';

class BoardViewScreen extends StatefulWidget {
  final int boardId;
  final int pageNo;

  BoardViewScreen({required this.boardId, required this.pageNo});

  @override
  _BoardViewScreenState createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  final TextEditingController _contentController = TextEditingController();
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  dynamic? _board;
  List<dynamic>? _reply;
  String? _token;

  @override
  void initState() {
    super.initState();
    _getBoard();
    _getReply();
  }

  Future<void> _getReply() async {
    try {
      _token = await _storage.read(key: 'jwt');
      if (_token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      _dio.options.headers["Authorization"] = "Bearer $_token";
      final response = await _dio
          .get("http://localhost:8080/api/reply/showAll/${widget.boardId}");
      setState(() {
        _reply = response.data["list"];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _writeReply() async {
    try {
      _token = await _storage.read(key: 'jwt');
      if (_token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      await _dio.post('http://localhost:8080/api/reply/write', data: {
        "content": _contentController.text,
        "boardId": widget.boardId
      });

      // 댓글 작성 후 댓글 리스트 업데이트
      await _getReply();

      // 댓글 작성 후 텍스트 필드 초기화
      _contentController.clear();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getBoard() async {
    try {
      _token = await _storage.read(key: 'jwt');
      if (_token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      _dio.options.headers["Authorization"] = "Bearer $_token";
      final response = await _dio
          .get("http://localhost:8080/api/board/showOne/${widget.boardId}");
      setState(() {
        _board = response.data["boardDTO"];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteBoard() async {
    try {
      await _dio.get('http://localhost:8080/api/board/delete/${widget.boardId}',
          options: Options(headers: {'Authorization': 'Bearer $_token'}));
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => BoardListScreen(pageNo: widget.pageNo)));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_board?["title"] ?? "불러오는 중..."),
        trailing: CupertinoButton.filled(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => BoardListScreen(pageNo: widget.pageNo),
              ),
            );
          },
          child: Icon(CupertinoIcons.backward),
        ),
      ),
      child: _board == null
          ? Center(child: CupertinoActivityIndicator())
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("제목: ${_board!["title"]}"),
                  Text("글 번호: ${_board!["id"]}"),
                  Text("작성자: ${_board!["nickname"]}"),
                  Text("작성일: ${_board!["formattedEntryDate"]}"),
                  Text("수정일: ${_board!["formattedModifyDate"]}"),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 600),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Html(data: _board!['content']),
                    ),
                  ),
                  if (_board!['owned']) ...[
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton.filled(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    BoardUpdateScreen(boardId: widget.boardId),
                              ),
                            );
                          },
                          child: Text('수정'),
                        ),
                        CupertinoButton.filled(
                          onPressed: _deleteBoard,
                          child: Text('삭제'),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 100),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _contentController,
                          placeholder: '댓글',
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CupertinoColors.opaqueSeparator,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        color: CupertinoColors.systemGreen,
                        padding: EdgeInsets.all(12),
                        borderRadius: BorderRadius.circular(8),
                        onPressed: _writeReply,
                        child: Text('댓글 작성'),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: _reply != null
                          ? _reply!.map((reply) {
                              return CupertinoListTile(
                                leading: Icon(CupertinoIcons.reply),
                                title: Text(reply['content']),
                                subtitle: Text(
                                    "${reply['nickname']} - ${reply['modifyDate']}"),
                              );
                            }).toList()
                          : [],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
