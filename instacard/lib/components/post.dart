import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instacard/common/tool.dart';
import 'package:instacard/components/imageView.dart';
import 'package:instacard/components/postview.dart';
import '../classes/post.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

// 概觀文章元件(Class Post, 是否為收藏文章, 是否為顯示廣告)
class PostCard extends StatefulWidget {
  const PostCard(
      {Key key, this.post, this.isFavorite = false, this.isAds = false})
      : super(key: key);
  final Post post;
  final bool isFavorite;
  final bool isAds;
  @override
  _PostCardState createState() => new _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // ad
  BannerAd ad;
  // 圖片指示器位置
  int _current = 0;
  // 收藏文章loading狀態
  bool loading = false;
  // 是否已收藏文章
  bool isSaved = false;
  // 媒體清單
  List<String> medias = [];
  @override
  void dispose() {
    super.dispose();
    if (ad != null) ad.dispose();
  }

  @override
  void initState() {
    // 當元件初始化完成時呼叫
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 快取所有圖片
      if (widget.post != null)
        widget.post.formatMedias.forEach((url) {
          precacheImage(CachedNetworkImageProvider(url), context);
        });
    });
    // loading 開啟原文網址的廣告
    // randomAd();
    if (widget.isAds) {
      ad = BannerAd(
          size: AdSize.mediumRectangle,
          adUnitId: Tool().getBannerAdUnitId(),
          request: AdRequest(),
          listener: AdListener());
      ad.load();
    } else {
      // 如果不是廣告再去確認是否有收藏
      Tool().checkIsFavorite(widget.post.id).then((value) {
        setState(() {
          isSaved = value;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 如果是廣告 回傳廣告
    if (widget.isAds) return buildAds();
    // // 如果是從收藏開啟的文章及沒有被收藏 應該不會
    // if (!isSaved && widget.isFavorite) return Container();

    // 副標題，顯示版塊名稱
    String subtitle = '${widget.post.forumName}版';
    // 設定發文時間轉換語系
    timeago.setLocaleMessages('zh', timeago.ZhMessages());
    // 如果文章有卡稱，加上卡稱
    if (widget.post.withNickname)
      subtitle = '$subtitle • ${widget.post.school}';
    // 回傳文章元件
    return buildPost(subtitle);
  }

  // ImageSlider元件
  Widget buildSlider() {
    if (widget.post == null) return Container();
    // 如果沒有媒體回傳空盒
    return widget.post.formatMedias.length < 1
        ? Container()
        : CarouselSlider(
            options: CarouselOptions(
                height: MediaQuery.of(context).size.width,
                viewportFraction: 1,
                aspectRatio: 1,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) => {
                      setState(() {
                        _current = index;
                      })
                    }),
            items: widget.post.formatMedias
                .asMap()
                .map((index, item) {
                  String url = item;
                  String trueUrl = widget.post.media[index]["url"].toString();
                  return MapEntry(
                      index,
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageView(
                                          url: trueUrl,
                                        )));

                            // FlutterWebBrowser.openWebPage(url: trueUrl);
                          },
                          // child: Image(
                          //   image: CachedNetworkImageProvider(url),
                          // ),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            // progressIndicatorBuilder:
                            //     (context, url, downloadProgress) => Center(
                            //   child: CircularProgressIndicator(
                            //       value: downloadProgress.progress),
                            // ),
                            placeholder: (context, url) => Container(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ));
                })
                .values
                .toList(),
          );
  }

  // 廣告元件
  Widget buildAds() {
    return Stack(
      children: [
        Column(children: [
          AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.face_rounded,
                  color: Colors.yellow.shade900,
                  size: 24,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('廣告', style: TextStyle(fontSize: 14)),
                Text(
                  '廣告小天使',
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
          SizedBox(
            width: 320,
            height: 270,
            child: Center(
              child: AdWidget(ad: ad),
            ),
          ),
        ]),
      ],
    );
  }

  // 概覽文章元件 (副標題)
  Widget buildPost(String subtitle) {
    return Stack(
      children: [
        Column(children: [
          // header標題列
          AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.face_rounded,
                  color: widget.post.gender == 'F'
                      ? Colors.redAccent.shade700
                      : Colors.blue.shade500,
                  size: 24,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.title.toString(),
                    style: TextStyle(fontSize: 14)),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
            actions: [
              IconButton(
                  icon: Icon(Icons.launch),
                  onPressed: () {
                    Tool().launchInBrowser(
                        'https:dcard.tw/f/${widget.post.forumAlias}/p/${widget.post.id}');
                  }),
            ],
          ),
          // 圖片區域
          buildSlider(),
          // 讚數 指示器 收藏按紐
          Row(children: [
            Container(
                width: 80,
                padding: EdgeInsets.only(left: 8),
                child: Text('${widget.post.likeCount}個讚')),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.post.media.map((item) {
                    int index = widget.post.media.indexOf((item));
                    return Container(
                      width: 6.0,
                      height: 6.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color.fromRGBO(3, 165, 252, 0.9)
                            : Color.fromRGBO(255, 255, 255, 0.4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 0),
              child: IconButton(
                  splashRadius: 24,
                  icon: Icon(isSaved ? Icons.turned_in : Icons.turned_in_not),
                  onPressed: () {
                    if (loading) return;
                    setState(() {
                      loading = true;
                    });
                    isSaved
                        ? Tool()
                            .removeFromFavorite(widget.post.id)
                            .then((value) {
                            setState(() {
                              loading = false;
                              isSaved = false;
                            });
                          })
                        : Tool().saveToFavorite(widget.post).then((value) {
                            setState(() {
                              loading = false;
                              isSaved = true;
                            });
                          });
                  }),
            ),
          ]),
          // 時間
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                child: Text(timeago
                    .format(widget.post.createdAt, locale: 'zh')
                    .replaceAll(' ', '')
                    .replaceAll('約', '')),
              ),
            ],
          ),
          // 文章概述
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new PostView(post: widget.post)),
                  );
                },
                child: Text('${widget.post.excerpt} ...更多內容')),
          ),
        ]),
        // 重疊在右上角的圖片位置指示器
        Align(
            alignment: Alignment.topRight,
            child: widget.post.media.length > 1
                ? Container(
                    width: 40.0,
                    height: 28.0,
                    margin: EdgeInsets.only(right: 24, top: 64),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      shape: BoxShape.rectangle,
                      color: Colors.black87,
                    ),
                    child: Center(
                      child:
                          Text('${_current + 1}/${widget.post.media.length}'),
                    ),
                  )
                : Container()),
      ],
    );
  }
}
