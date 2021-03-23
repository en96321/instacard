import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../classes/post.dart';
import '../classes/fullpost.dart';
import '../classes/forum.dart';
import '../classes/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DCARD API
class API {
  // 取得版塊文章(版塊ID, 熱門)
  Future<List<Post>> fetchPosts(String forum, bool isHot) async {
    // 取得SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 取得版塊概覽文章
    final response = await http.get(
        Uri.https('www.dcard.tw', '_api/forums/$forum/posts?popular=$isHot'));
    // if success
    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      // 取得是否顯示沒有圖片的文章
      bool showNoImagePost = prefs.containsKey('showNoImagePost')
          ? prefs.getBool('showNoImagePost')
          : false;
      // 格式化為概覽文章Post Class並過濾置頂文章
      return responseJson
          .map((m) => new Post.fromJson(m))
          .toList()
          .where((post) =>
              (post.media.length > 0 || showNoImagePost) && !post.pinned)
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得版塊更多文章(版塊ID, 文章ID, 熱門)
  Future<List<Post>> fetchMorePosts(
      String forum, int before, bool isHot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.https('www.dcard.tw',
        '_api/forums/$forum/posts?popular=$isHot&before=${before.toString()}'));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      bool showNoImagePost = prefs.containsKey('showNoImagePost')
          ? prefs.getBool('showNoImagePost')
          : false;
      return responseJson
          .map((m) => new Post.fromJson(m))
          .toList()
          .where((post) =>
              (post.media.length > 0 || showNoImagePost) && !post.pinned)
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得所有文章(熱門)
  Future<List<Post>> fetchAllPosts(bool isHot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response =
        await http.get(Uri.https('www.dcard.tw', '_api/posts?popular=$isHot'));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      bool showNoImagePost = prefs.containsKey('showNoImagePost')
          ? prefs.getBool('showNoImagePost')
          : false;
      return responseJson
          .map((m) => new Post.fromJson(m))
          .toList()
          .where((post) =>
              (post.media.length > 0 || showNoImagePost) && !post.pinned)
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得更多所有文章(文章ID, 熱門)
  Future<List<Post>> fetchMoreAllPosts(int before, bool isHot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.https('www.dcard.tw',
        '_api/posts?popular=$isHot&before=${before.toString()}'));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      bool showNoImagePost = prefs.containsKey('showNoImagePost')
          ? prefs.getBool('showNoImagePost')
          : false;
      return responseJson
          .map((m) => new Post.fromJson(m))
          .toList()
          .where((post) =>
              (post.media.length > 0 || showNoImagePost) && !post.pinned)
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得完整文章(id)
  Future<FullPost> fetchFullPost(int id) async {
    final response =
        await http.get(Uri.https('www.dcard.tw', '_api/posts/$id'));

    if (response.statusCode == 200) {
      // 轉換為Full Post Class
      return new FullPost.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得留言(文章id)
  Future<List<Comment>> fetchPostComments({int id, int after = 0}) async {
    final response = await http.get(Uri.https(
        'www.dcard.tw', '_api/posts/$id/comments?after=$after&limit=100'));
    log('_api/posts/$id/comments?after=$after&limit=100');
    if (response.statusCode == 200) {
      // 轉換為comment Class
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new Comment.fromJson(m)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得熱門留言(文章id)
  Future<List<Comment>> fetchPostPopularComments(int id) async {
    final response = await http
        .get(Uri.https('www.dcard.tw', '_api/posts/$id/comments?popular=true'));

    if (response.statusCode == 200) {
      // 轉換為comment Class
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new Comment.fromJson(m)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  // 取得版塊列表
  Future<List<Forum>> fetchForums() async {
    final response = await http.get(Uri.https('www.dcard.tw', '_api/forums'));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      // 轉換為版塊Class清單
      List<Forum> l = responseJson.map((m) => new Forum.fromJson(m)).toList();
      // 排序
      l.sort((a, b) => a.subscriptionCount.compareTo(b.subscriptionCount));
      // 逆轉排序傳回
      return l.reversed.toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
