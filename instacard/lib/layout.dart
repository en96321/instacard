import 'package:flutter/material.dart';
import 'package:instacard/pages/explore.dart';
import 'package:instacard/pages/favorite.dart';
import 'package:instacard/pages/posts.dart';
import 'package:instacard/pages/setting.dart';

// 主框架
class Layout extends StatefulWidget {
  Layout({Key key, this.defaultForum = ''}) : super(key: key);
  final String defaultForum;
  @override
  LayoutState createState() => new LayoutState();
}

class LayoutState extends State<Layout> {
  int tabIndex = 0;
  Posts posts = new Posts();
  Explore explore = new Explore();
  Favorite favorite = new Favorite();
  Setting setting = new Setting();
  List<Widget> pages;
  List<BottomNavigationBarItem> mainTabs = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_filled),
        label: 'InstaCard',
        tooltip: ''),
    BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: '探索',
        tooltip: ''),
    BottomNavigationBarItem(
        icon: Icon(Icons.turned_in_not),
        activeIcon: Icon(Icons.turned_in),
        label: '收藏',
        tooltip: ''),
    BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: '設定',
        tooltip: ''),
  ];

  @override
  void initState() {
    super.initState();
    // 頁面
    pages = [posts, explore, favorite, setting];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: IndexedStack(
        children: pages,
        index: tabIndex,
      ),
      bottomNavigationBar: new BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: tabIndex,
        onTap: (index) {
          // 在同頁面且在按一次tab時 呼叫各頁面重新整理
          if (index == tabIndex)
            switch (index) {
              case 0:
                posts.load();
                break;
              case 1:
                explore.load();
                break;
              default:
            }
          else {
            // 切換頁面時
            favorite.load();
            setState(() {
              tabIndex = index;
            });
          }
        },
        items: mainTabs,
      ),
    );
  }
}
