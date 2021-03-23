import 'package:flutter/material.dart';
import 'package:instacard/common/tool.dart';

// Dcard完整文章Class
class FullPost {
  // 標題
  final String title;
  // 內文，已轉換為Widget
  final List<Widget> content;
  // 媒體列
  final List<dynamic> media;

  FullPost({this.title, this.content, this.media});

  factory FullPost.fromJson(Map<String, dynamic> json) {
    List<Widget> formatedContent =
        Tool().formatContent(json["content"].toString());
    return FullPost(
        title: json['title'], content: formatedContent, media: json['media']);
  }
}
