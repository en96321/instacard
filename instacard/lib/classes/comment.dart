// Dcard留言Class
import 'package:flutter/material.dart';
import 'package:instacard/common/tool.dart';

class Comment {
  // 學校，卡稱
  final String school;
  // 性別
  final String gender;
  // 樓層
  final int floor;
  // 讚數
  final int likeCount;
  // 內文，已轉換為Widget
  final List<Widget> content;
  // 留言時間
  final DateTime createdAt;
  // 是否被刪除
  final bool hidden;
  // 是否為原PO
  final bool host;
  Comment(
      {this.school,
      this.gender,
      this.floor,
      this.likeCount,
      this.content,
      this.createdAt,
      this.hidden,
      this.host});

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Widget> formatedContent =
        Tool().formatContent(json["content"].toString());
    return Comment(
        school: json['school'],
        gender: json['gender'],
        floor: json['floor'],
        likeCount: json['likeCount'],
        content: formatedContent,
        createdAt: DateTime.parse(json['createdAt']),
        hidden: json['hidden'],
        host: json['host']);
  }
}
