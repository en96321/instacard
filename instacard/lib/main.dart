import 'package:flutter/material.dart';
import 'package:instacard/layout.dart';
// import 'package:admob_flutter/admob_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  // debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids
  MobileAds.instance.initialize();
  runApp(DcardImage());
}

class DcardImage extends StatefulWidget {
  @override
  _DcardImageState createState() => _DcardImageState();
}

class _DcardImageState extends State<DcardImage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    // 建立Meterial Style APP 還有IOS STYLE的Cupertino style
    return MaterialApp(
      // 設定主題
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
        ),
      ),
      // 啟動主體框架
      home: Layout(),
    );
  }
}
