import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instacard/classes/fullpost.dart';
import 'package:instacard/classes/post.dart';
import 'package:instacard/common/api.dart';
import 'package:instacard/common/tool.dart';
import '../components/comment.dart';

// 完整文章顯示
class PostView extends StatefulWidget {
  const PostView({Key key, this.post}) : super(key: key);
  final Post post;

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  List<Widget> popularComments = [];
  List<Widget> comments = [];
  // ad
  BannerAd ad;
  // 留言讀取中
  bool loading = true;
  // 是否還能讀取
  bool loadable = true;
  // 是否顯示全部留言
  bool commentIsShow = false;
  void _getPopularComments() {
    setState(() {
      loading = true;
    });
    API().fetchPostPopularComments(widget.post.id).then((value) {
      popularComments.addAll(value.map((e) {
        return new CommentView(
          comment: e,
        );
      }).toList());
      setState(() {
        loading = false;
      });
    });
  }

  void _getComments(int after) {
    setState(() {
      loading = true;
    });
    API().fetchPostComments(id: widget.post.id, after: after).then((value) {
      comments.addAll(value.map((e) {
        return new CommentView(
          comment: e,
        );
      }).toList());
      if (value.length < 100) {
        comments.add(Container(
          child: Center(
            child: Text('-沒有更多留言了-'),
          ),
        ));
        loadable = false;
        setState(() {
          commentIsShow = true;
          loading = false;
        });
      } else {
        _getComments(value[99].floor);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getPopularComments();
    });
    ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Tool().getPostBannerAdUnitId(),
        request: AdRequest(),
        listener: AdListener());
    ad.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: FutureBuilder(
        // 等待讀取完成才顯示文章
        future: API().fetchFullPost(widget.post.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          // 讀取完成的資料為FullPost Class
          FullPost fpost = snapshot.data;
          return SingleChildScrollView(
            child: ListBody(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: fpost.content,
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 60,
                    child: Center(
                      child: AdWidget(ad: ad),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white70,
                ),
                Container(
                  child: Center(
                    child: Text('熱門留言'),
                  ),
                ),
                Divider(
                  color: Colors.white70,
                ),
                ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    cacheExtent: 600,
                    itemBuilder: (context, index) => popularComments[index],
                    separatorBuilder: (context, index) => new Divider(
                          color: Colors.white70,
                        ),
                    itemCount: popularComments.length),
                Divider(
                  color: Colors.white70,
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      if (!commentIsShow) _getComments(0);
                    },
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Center(
                            child: Text(commentIsShow ? '全部留言' : '顯示全部留言'),
                          ),
                  ),
                ),
                Divider(
                  color: Colors.white70,
                ),
                ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => comments[index],
                    separatorBuilder: (context, index) => new Divider(
                          color: Colors.white70,
                        ),
                    itemCount: comments.length),
              ],
            ),
          );
        },
      ),
    );
  }
}
