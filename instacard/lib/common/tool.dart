import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instacard/classes/post.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:url_launcher/url_launcher.dart';

// InstaCard 通用工具類別
class Tool {
  // 讀取收藏文章清單
  Future<List<Post>> readFavorites() async {
    // open db
    Database db = await getDatabase();
    // get main db
    var store = StoreRef.main();
    // get all favorite posts
    var posts = (await store.find(db));
    List<Post> favorites = [];
    // transform posts json string to Post Class
    posts.forEach((element) {
      Map<String, dynamic> e =
          Map<String, dynamic>.from(json.decode(element.value));
      favorites.add(new Post.fromJson(e));
    });
    return favorites;
  }

  // 移除收藏(文章ID)
  Future<bool> removeFromFavorite(int id) async {
    Database db = await getDatabase();
    var store = StoreRef.main();
    var posts = (await store.find(db));
    int key = -1;
    // 搜尋id 相同並取得資料庫內key
    posts.forEach((element) {
      Map<String, dynamic> e =
          Map<String, dynamic>.from(json.decode(element.value));
      if (id.toString() == e["id"].toString()) key = element.key;
    });
    // 如果key > -1 代表有找到 刪除收藏
    if (key >= 0) store.record(key).delete(db);
    return true;
  }

  // 收藏文章(概覽文章Class)
  Future<bool> saveToFavorite(Post post) async {
    Database db = await getDatabase();
    var store = StoreRef.main();
    // 轉換回json string存進db
    await store.add(db, json.encode(post));
    return true;
  }

  // 取得db
  Future<Database> getDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, 'instacard.db');
    DatabaseFactory dbFactory = databaseFactoryIo;

    // We use the database factory to open the database
    Database db = await dbFactory.openDatabase(dbPath);
    return db;
  }

  // 開啟網址
  Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  // 確認是否為收藏文章(文章ID)
  Future<bool> checkIsFavorite(id) async {
    bool found = false;
    Database db = await getDatabase();
    var store = StoreRef.main();
    var posts = (await store.find(db));
    for (int i = 0; i < posts.length; i++) {
      Map<String, dynamic> e =
          Map<String, dynamic>.from(json.decode(posts[i].value));
      if (e["id"].toString() == id.toString()) {
        found = true;
        i = posts.length;
      }
    }
    return found;
  }

  List<Widget> formatContent(String content) {
    // 用換行分割內文
    List<String> splitContents = content.split('\n');
    // 註冊imgur圖片網址的正規表達式
    RegExp imgurRegex = new RegExp(
        "(http|https):\/\/i\.imgur\.com\/[a-zA-Z0-9\.\/_]+",
        caseSensitive: false,
        multiLine: false);
    // 註冊一般網址的表達式
    RegExp defaultRegex = new RegExp(
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#\\[\\]@!\\\$&'\\(\\)\\*\\+,;=.]+\$",
        caseSensitive: false,
        multiLine: false);
    // 格式化內文為元件
    List<Widget> formatedContent = splitContents.map((e) {
      // match ingur regex
      String matchImage = imgurRegex.stringMatch(e).toString();
      // 因轉換為string所以改為判斷'null'
      if (matchImage != 'null') {
        // 置中快取圖片元件

        return Center(
            child: Container(
                child: CachedNetworkImage(
          imageUrl: matchImage,
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
        )));
      }
      // match link regex
      String matchLink = defaultRegex.stringMatch(e).toString();
      if (matchLink != 'null') {
        return GestureDetector(
            onTap: () {
              // 點擊後打開網址
              Tool().launchInBrowser(matchLink);
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white24, width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                matchLink,
              ),
            ));
      }
      // 一般文字
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          e,
          style: TextStyle(fontSize: 16),
        ),
      );
    }).toList();
    return formatedContent;
  }

  // 根據裝置類型取得Banner廣告ID
  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-5369971011451124/9038437910';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5369971011451124/9038437910';
    }
    return null;
  }

  // 根據裝置類型取得Banner廣告ID
  String getPostBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-5369971011451124/1493121827';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5369971011451124/1493121827';
    }
    return null;
  }

  // 根據裝置類型取得Interstitial廣告ID
  String getInterstitialAdUniId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-5369971011451124/4731984090';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5369971011451124/4731984090';
    }
    return null;
  }

  String getRewardAdUintId() {
    return 'ca-app-pub-5369971011451124/2596166530';
  }
}
