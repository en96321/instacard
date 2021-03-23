import 'package:flutter/material.dart';
import '../classes/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentView extends StatelessWidget {
  const CommentView({Key key, this.comment}) : super(key: key);
  final Comment comment;
  @override
  Widget build(BuildContext context) {
    return comment.hidden
        ? Container(
            child: Center(
              child: Text('已經被刪除的留言'),
            ),
          )
        : Container(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.face_rounded,
                      color: comment.gender == 'F'
                          ? Colors.redAccent.shade700
                          : Colors.blue.shade500,
                      size: 24,
                    ),
                  ),
                  title: Text(comment.host
                      ? '原PO'
                      : comment.school == null
                          ? '匿名'
                          : comment.school),
                  subtitle: Text(
                      '${timeago.format(comment.createdAt, locale: 'zh').replaceAll(' ', '').replaceAll('約', '')} • ${comment.likeCount}個讚'),
                  trailing: Text('B${comment.floor}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, right: 16, bottom: 16, left: 16),
                  child: Column(
                    children: comment.content,
                  ),
                ),
              ],
            ),
          );
  }
}
