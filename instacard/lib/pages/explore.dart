import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/post.dart';
import '../common/api.dart';

// 探索頁
class Explore extends StatefulWidget {
  Explore({Key key}) : super(key: key);
  final _ExploreState exploreState = new _ExploreState();
  @override
  _ExploreState createState() => exploreState;
  // 建立一個可以外呼的Function，用來重新整理Post list
  void load() {
    exploreState._refreshController.requestRefresh();
  }
}

class _ExploreState extends State<Explore> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  // 文章清單
  List<PostCard> posts = [];
  // 是否還能讀取
  bool loadable = true;
  // 是否為熱門
  bool isHot = true;
  // 已插入的廣告數
  int adsCount = 0;

  // 讀取所有文章
  void _load() async {
    adsCount = 0;
    API().fetchAllPosts(isHot).then((resPosts) {
      // 如果回傳的文章數為0代表沒有更多文章了
      if (resPosts.length < 1) {
        setState(() {
          posts = [];
          loadable = false;
          // 增加一個空文章卡用來顯示為沒有更多文章
          posts.add(new PostCard(
            key: UniqueKey(),
          ));
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
          API().fetchMoreAllPosts(posts[index].post.id, isHot).then((resPosts) {
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
                  int nowIndex = baseLength + i;
                  if (nowIndex % 7 == 0) {
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
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('探索'),
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
          child: buildPosts(),
          onRefresh: () async {
            _load();
          },
        ));
  }
}
