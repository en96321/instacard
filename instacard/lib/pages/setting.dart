import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 設定頁
class Setting extends StatefulWidget {
  Setting({Key key}) : super(key: key);
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  // 隱藏不包含圖片的文章
  bool showNoImagePost = false;
  // 隱藏成人內容
  bool showNSFW = false;
  bool showHideSetting = false;
  int count = 0;
  @override
  void initState() {
    _loadSetting();
    super.initState();
  }

  // 讀取設定
  void _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showNoImagePost = prefs.containsKey('showNoImagePost')
          ? prefs.getBool('showNoImagePost')
          : false;
      showNSFW =
          prefs.containsKey('showNSFW') ? prefs.getBool('showNSFW') : false;
      showHideSetting = prefs.containsKey('showHideSettings')
          ? prefs.getBool('showHideSettings')
          : false;
    });
  }

  // 寫入設定
  void _writeSetting(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('基本設定'),
        ),
        ListTile(
          leading: Icon(Icons.image_not_supported),
          title: Text('顯示不包含圖片的文章'),
          trailing: Switch(
              value: showNoImagePost,
              onChanged: (value) {
                _writeSetting('showNoImagePost', !showNoImagePost);
                _loadSetting();
              }),
        ),
        Container(
          child: !showHideSetting
              ? Container()
              : ListTile(
                  leading: Icon(Icons.warning),
                  title: Text('顯示敏感性板塊'),
                  trailing: Switch(
                      value: showNSFW,
                      onChanged: (value) {
                        _writeSetting('showNSFW', !showNSFW);
                        _loadSetting();
                      }),
                ),
        ),
        ListTile(
          title: Text('關於'),
        ),
        ListTile(
          leading: GestureDetector(
            child: Icon(Icons.info),
            onTap: () {
              if (count > 10) {
                setState(() {
                  _writeSetting('showHideSettings', true);
                  _loadSetting();
                });
              }
              count++;
            },
          ),
          title: Text('應用程式版本'),
          subtitle: Text('1.0.0'),
        ),
      ],
    );
  }
}
