// Dcard版塊Class
class Forum {
  // 別名，版塊id
  final String alias;
  // 顯示名稱
  final String name;
  // 訂閱數量，用來判斷熱門程度
  final int subscriptionCount;
  // 是否為成人內容
  final bool nsfw;

  Forum({this.alias, this.name, this.nsfw, this.subscriptionCount});

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
        alias: json['alias'],
        name: json['name'],
        nsfw: json['nsfw'],
        subscriptionCount: json['subscriptionCount']);
  }
}
