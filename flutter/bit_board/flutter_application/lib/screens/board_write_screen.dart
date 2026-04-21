import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/screens/board_view_screen.dart';
import 'package:flutter_application/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'dart:convert';

class BoardWriteScreen extends StatefulWidget {
  @override
  _BoardWriteScreenState createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _contentController = QuillController.basic();
  final Dio _dio = Dio();
  final storage = FlutterSecureStorage();
  bool _isSubmitting = false;

  Future<void> _writeBoard() async {
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

      final Response = await _dio.post("http://localhost:8080/api/board/write",
          data: {"title": _titleController.text, "content": convertedData});

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
        middle: Text("새 글 작성하기"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSubmitting ? null : _writeBoard,
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
