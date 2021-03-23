import 'package:flutter/material.dart';
import 'package:instacard/classes/forum.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 顯示板塊列表選擇(版塊列表, 選擇後觸發function並傳回版塊ID)
class Forums extends StatefulWidget {
  const Forums({Key key, this.forums, this.selectForum}) : super(key: key);

  final List<Forum> forums;
  final Function selectForum;

  @override
  _ForumsState createState() => _ForumsState();
}

class _ForumsState extends State<Forums> {
  TextEditingController _searchQueryController = TextEditingController();
  List<Forum> fillterForums = [];

  @override
  void initState() {
    super.initState();
    // init初始清單
    _searchForum('').then((value) {
      setState(() {
        fillterForums = value;
      });
    });
  }

  Future<List<Forum>> _searchForum(value) async {
    // 取得設定是否顯示成人內容
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showNSFW =
        prefs.containsKey('showNSFW') ? prefs.getBool('showNSFW') : false;
    // 過濾成人內容及搜尋內容
    return value == ''
        ? widget.forums.where((element) => (!element.nsfw || showNSFW)).toList()
        : widget.forums
            .where((element) =>
                (element.alias.indexOf(value) >= 0 ||
                    element.name.indexOf(value) >= 0) &&
                (!element.nsfw || showNSFW))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: TextField(
            controller: _searchQueryController,
            decoration: InputDecoration(
              hintText: "搜尋板塊",
              filled: true,
              fillColor: Colors.white,
              hintStyle: TextStyle(color: Colors.black),
            ),
            style: TextStyle(color: Colors.black87, fontSize: 16.0),
            onChanged: (value) {
              _searchForum(value).then((forums) {
                setState(() {
                  fillterForums = forums;
                });
              });
            },
          ),
        ),
        body: fillterForums.length < 1
            ? Center(
                child: Text('沒有找到板塊'),
              )
            : ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      widget.selectForum(fillterForums[index]);
                      Navigator.pop(context);
                    },
                    title: Text(fillterForums[index].name),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemCount: fillterForums.length,
              ),
      ),
    );
  }
}
