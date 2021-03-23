import 'package:flutter/material.dart';
import 'package:instacard/classes/forum.dart';
import 'package:instacard/components/forums.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/post.dart';
import '../common/api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 版塊文章瀏覽框架 在此class只讀取版塊清單及預設板塊以防止多次請求
class Posts extends StatefulWidget {
  Posts({Key key}) : super(key: key);

  final _PostsState postsState = new _PostsState();
  @override
  _PostsState createState() => postsState;
  // 重新整理頁
  void load() {
    postsState.load();
  }
}

class _PostsState extends State<Posts> {
  PostsBody posts;
  // 讀取設定的預設板塊
  Future<String> _loadDefaultForum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('defaultForum')
        ? prefs.getString('defaultForum')
        : '';
  }

  // 呼叫版塊文章的重新整理
  void load() {
    posts.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        // 等待版塊列表及預設板塊讀取完成
        future: Future.wait([API().fetchForums(), _loadDefaultForum()]),
        builder: (context, snapshot) {
          // 讀取中 黑屏就好
          if (!snapshot.hasData) return Container();
          // 建立版塊文章主體
          posts =
              new PostsBody(forums: snapshot.data[0], alias: snapshot.data[1]);
          return posts;
        },
      ),
    );
  }
}

// 版塊文章主體 (需有版塊列表及預設的版塊ID)
class PostsBody extends StatefulWidget {
  PostsBody({Key key, this.forums, this.alias}) : super(key: key);
  final List<Forum> forums;
  final String alias;
  final _PostsBodyState postsBodytate = new _PostsBodyState();
  @override
  _PostsBodyState createState() => postsBodytate;
  // 重新整理func
  void load() {
    postsBodytate._refreshController.requestRefresh();
  }
}

class _PostsBodyState extends State<PostsBody> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<PostCard> posts = [];
  bool loadable = true;
  bool isHot = true;
  String alias;
  // 已插入的廣告數
  int adsCount = 0;
  @override
  void initState() {
    // init預設板塊
    alias = widget.alias;
    super.initState();
  }

  // 取得現在所在版塊名稱
  String getNowForumName() {
    if (alias == "") return "請選擇預設板塊";
    return widget.forums.firstWhere((element) => element.alias == alias).name;
  }

  // 設定板塊及寫入預設版塊
  void _setForum(forumAlias) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultForum', forumAlias);
    setState(() {
      alias = forumAlias;
    });
    // 請求重新整理
    _refreshController.requestRefresh();
  }

  // 已底部資訊欄方式顯示版塊列表
  void showForum(context) {
    showBarModalBottomSheet(
        expand: true,
        context: context,
        backgroundColor: Colors.black,
        builder: (context) {
          return Forums(
            // 傳入版塊清單
            forums: widget.forums,
            // 選擇版塊後func
            selectForum: (f) {
              _setForum(f.alias);
            },
          );
        });
  }

  // 讀取文章
  void _load() async {
    adsCount = 0;
    // 如果所在版塊為'' 則不動作
    if (alias == '') return;
    API().fetchPosts(alias, isHot).then((resPosts) {
      // 如果回傳的文章數為0代表沒有更多文章了
      if (resPosts.length < 1) {
        setState(() {
          posts = [];
          loadable = false;
          // 增加一個空文章卡用來顯示為沒有更多文章
          posts.add(new PostCard());
        });
      } else {
        // 將回傳的資料建立為概覽文章Widget
        setState(() {
          posts = [];
          for (int i = 0; i < resPosts.length; i++) {
            // 建立成廣告
            if (i % 7 == 0 && i != 0) {
              adsCount++;
              posts.add(new PostCard(
                isAds: true,
              ));
              posts.add(new PostCard(
                post: resPosts[i],
              ));
            } else
              posts.add(new PostCard(post: resPosts[i]));
          }
        });
      }
      // 通知控制器重新整理完成
      _refreshController.refreshCompleted();
    });
  }

  // 建立文章清單元件
  Widget buildPosts() {
    return ListView.separated(
      cacheExtent: 500,
      padding: new EdgeInsets.all(0.0),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        // 當到達最後一篇文章時
        if (index == posts.length - 1) {
          // 如果不能讀取了 代表要顯示為沒有更多文章
          if (!loadable)
            return Container(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('-沒有更多文章了-')));
          // 嘗試讀取更多文章
          API()
              .fetchMorePosts(alias, posts[index].post.id, isHot)
              .then((resPosts) {
            int baseLength = posts.length - adsCount;
            if (resPosts.length < 1)
              setState(() {
                loadable = false;
                posts.add(new PostCard());
              });
            else
              setState(() {
                for (int i = 0; i < resPosts.length; i++) {
                  // 建立成廣告
                  // 目前實際文章位置
                  int nowIndex = baseLength + i;
                  if (nowIndex % 7 == 0) {
                    adsCount++;
                    posts.add(new PostCard(
                      isAds: true,
                    ));
                    posts.add(new PostCard(
                      post: resPosts[i],
                    ));
                  } else
                    posts.add(new PostCard(post: resPosts[i]));
                }
              });
          });
        }
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
          title: Row(
            children: [
              Text('Instacard'),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Transform(
                  transform: new Matrix4.identity()..scale(0.8),
                  child: GestureDetector(
                    onTap: () {
                      showForum(context);
                    },
                    child: Chip(
                      label: Text(getNowForumName()),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isHot ? Icons.whatshot : Icons.history),
              onPressed: () {
                setState(() {
                  isHot = !isHot;
                });
                _refreshController.requestRefresh();
              },
            ),
          ],
        ),
        body: SmartRefresher(
          controller: _refreshController,
          child: alias == ''
              ? Center(
                  child: Text('請從上方選取一個預設板塊'),
                )
              : buildPosts(),
          onRefresh: () async {
            if (alias == '') {
              showForum(context);
              _refreshController.refreshCompleted();
            } else {
              _load();
            }
          },
        ));
  }
}
