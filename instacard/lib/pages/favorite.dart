import 'package:flutter/material.dart';
import '../common/tool.dart';
import '../components/post.dart';

// 收藏頁
class Favorite extends StatefulWidget {
  Favorite({Key key}) : super(key: key);

  final _FavoriteState favoriteState = new _FavoriteState();
  @override
  _FavoriteState createState() => favoriteState;
  // 用來重新整理收藏頁的func
  void load() {
    favoriteState._loadFavorite();
  }
}

class _FavoriteState extends State<Favorite> {
  // 收藏的文章清單
  List<PostCard> posts = [];
  // 是否讀取中
  bool loading = true;
  @override
  void initState() {
    super.initState();
    // 讀取收藏文章
    _loadFavorite();
  }

  void _loadFavorite() async {
    setState(() {
      loading = true;
    });
    Tool().readFavorites().then((value) {
      setState(() {
        loading = false;
        posts = value.map((e) => new PostCard(post: e)).toList();
      });
    });
  }

  Widget buildBody() {
    // 如果讀取中 回傳讀取
    if (loading)
      return Center(
        child: CircularProgressIndicator(),
      );
    // 讀取完成但沒有收藏
    if (posts.length < 1)
      return Center(
        child: Text(
          '暫時沒有收藏',
          style: TextStyle(color: Colors.white),
        ),
      );
    // 有收藏
    return ListView.separated(
      cacheExtent: 3000,
      padding: new EdgeInsets.all(0.0),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return posts[index];
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        color: Colors.white30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏'),
      ),
      body: buildBody(),
    );
  }
}
