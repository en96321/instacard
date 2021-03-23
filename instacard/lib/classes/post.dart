// Dcard Post概覽 Class
class Post {
  // 標題
  final String title;
  // 性別
  final String gender;
  // 簡述
  final String excerpt;
  // 版塊ID
  final String forumAlias;
  // 版塊名稱
  final String forumName;
  // 學校或卡稱
  final String school;
  // 系所
  final String department;
  // 讚數
  final int likeCount;
  // 是否置頂
  final bool pinned;
  // 是否使用卡稱
  final bool withNickname;
  // 原始媒體列表 [{url: ''},..]
  final List<dynamic> media;
  // 格式化媒體列表 [String,..]
  final List<dynamic> formatMedias;
  // 文章ID
  final int id;
  // 文章建立時間
  final DateTime createdAt;

  Post(
      {this.title,
      this.gender,
      this.excerpt,
      this.id,
      this.media,
      this.formatMedias,
      this.pinned,
      this.likeCount,
      this.forumAlias,
      this.forumName,
      this.school,
      this.department,
      this.withNickname,
      this.createdAt});

  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic> medias;
    // 確認是否為從收藏撈出的文章 (會有已格式化的媒體清單)
    if (json.containsKey('formatMedias'))
      medias = json['formatMedias'];
    else {
      // 格式化imgur網址，改為縮圖尺寸 [s|m|l].jpg 及統一https
      medias = json['media'].map((e) {
        String url = e["url"].toString();
        if (url.indexOf('imgur') > -1) {
          if (url.indexOf('jpg') < 0 && url.indexOf('png') < 0)
            url = '${url}l.jpg';
          else
            url = url.replaceAll('.jpg', 'l.jpg').replaceAll('.png', 'l.jpg');
        }
        return url.replaceAll('https', 'http').replaceAll('http', 'https');
      }).toList();
    }
    return Post(
        title: json['title'],
        gender: json['gender'],
        excerpt: json['excerpt'],
        id: json['id'],
        media: json['media'],
        formatMedias: medias,
        likeCount: json['likeCount'],
        pinned: json['pinned'],
        forumAlias: json['forumAlias'],
        forumName: json['forumName'],
        school: json['school'],
        department: json['department'],
        withNickname: json['withNickname'],
        createdAt: DateTime.parse(json['createdAt']));
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'gender': gender,
      'excerpt': excerpt,
      'id': id,
      'media': media,
      'formatMedias': formatMedias,
      'likeCount': likeCount,
      'pinned': pinned,
      'forumAlias': forumAlias,
      'forumName': forumName,
      'school': school,
      'department': department,
      'withNickname': withNickname,
      'createdAt': createdAt.toIso8601String()
    };
  }
}
