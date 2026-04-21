import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/screens/board_view_screen.dart';
import 'package:flutter_application/screens/board_write_screen.dart';
import 'package:flutter_application/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BoardListScreen extends StatefulWidget {
  final int pageNo;
  BoardListScreen({required this.pageNo});

  //const BoardListScreen({super.key});

  @override
  _BoardListScreenState createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  final storage = FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> _boards = [];
  bool _isLoading = true;

  int _currentPage = 1;
  int _startPage = 1;
  int _endPage = 5;
  int _maxPage = 5;

  String? token;

  @override
  void initState() {
    super.initState();
    _getBoards();
  }

  Future<void> _getBoards() async {
    try {
      String? token = await storage.read(key: 'jwt');

      _currentPage = widget.pageNo;

      if (token == null) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => LoginScreen()));
      }

      _dio.options.headers["Authorization"] = "Bearer $token";
      await _getBoardsByPageNo(_currentPage);
    } catch (e) {
      //print(e);
    }
  }

  Future<void> _getBoardsByPageNo(int pageNo) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await _dio.get('http://localhost:8080/api/board/showAll/$pageNo');
      setState(() {
        _boards = response.data['list'];
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

  void _changePage(int pageNo) {
    if (pageNo >= 1 && pageNo <= _maxPage) {
      _getBoardsByPageNo(pageNo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('게시판'),
      ),
      child: Column(
        children: [
          Expanded(
              child: _isLoading
                  ? Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                      itemCount: _boards.length,
                      itemBuilder: (context, index) {
                        final board = _boards[index];
                        return CupertinoListTile(
                          leading: Icon(CupertinoIcons.doc_text),
                          title: Text(board['title']),
                          subtitle: Text(
                              "${board['nickname']} -${board['formattedEntryDate']}"),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => BoardViewScreen(
                                          boardId: board['id'],
                                          pageNo: _currentPage,
                                        )));
                          },
                        );
                      },
                    )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton.filled(
                onPressed: () => {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => BoardWriteScreen()))
                },
                child: Icon(CupertinoIcons.add_circled_solid),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: () => _changePage(1),
                  child: Text('<<'),
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
                  child: Text('>>'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
