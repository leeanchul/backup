import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/screens/board_view_screen.dart';
import 'package:flutter_application/screens/login_screen.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'dart:convert';

class BoardUpdateScreen extends StatefulWidget {
  final int boardId;
  BoardUpdateScreen({required this.boardId});

  @override
  _BoardUpdateScreenState createState() => _BoardUpdateScreenState();
}

class _BoardUpdateScreenState extends State<BoardUpdateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _contentController = QuillController.basic();
  final Dio _dio = Dio();
  final storage = FlutterSecureStorage();
  bool _isSubmitting = false;
  dynamic _board;

  @override
  void initState() {
    super.initState();
    _getBoard();
  }

  Future<void> _getBoard() async {
    String? token = await storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }

    _dio.options.headers["Authorization"] = "Bearer $token";

    final response = await _dio
        .get("http://localhost:8080/api/board/showOne/${widget.boardId}");

    setState(() {
      _board = response.data["boardDTO"];
    });

    _titleController.text = _board['title'];
    String html = _board['content'];
    var delta = HtmlToDelta().convert(html);
    _contentController.document = Document.fromDelta(delta);
  }

  Future<void> _updateBoard() async {
    setState(() {
      _isSubmitting = true;
    });

    String? token = await storage.read(key: "jwt");

    if (token == null) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }

    try {
      final deltaJson = _contentController.document.toDelta().toJson();

      final QuillDeltaToHtmlConverter converter;

      converter = QuillDeltaToHtmlConverter(
        List<Map<String, dynamic>>.from(deltaJson),
      );

      final convertedData = converter.convert();

      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Content-Type'] = 'application/json';

      final Response = await _dio.post(
        "http://localhost:8080/api/board/update",
        data: {
          "id": widget.boardId,
          "title": _titleController.text,
          "content": convertedData
        },
      );

      setState(() {
        _isSubmitting = false;
      });
      dynamic data = Response.data["boardDTO"];
      int id = data['id'];

      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => BoardViewScreen(
                    boardId: id,
                    pageNo: 1,
                  )));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("${widget.boardId}번 글 수정하기"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSubmitting ? null : _updateBoard,
          child: Icon(CupertinoIcons.square_pencil),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(80),
        child: Column(
          children: [
            CupertinoTextField(
              controller: _titleController,
              placeholder: "제목",
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: CupertinoColors.systemBrown,
                  borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: Column(
              children: [
                QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                      controller: _contentController),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(8)),
                    child: QuillEditor.basic(
                        configurations: QuillEditorConfigurations(
                            controller: _contentController)),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
