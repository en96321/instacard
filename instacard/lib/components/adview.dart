import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instacard/common/tool.dart';

class AdView extends StatelessWidget {
  AdView({Key key}) : super(key: key);
  final BannerAd ad = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: Tool().getBannerAdUnitId(),
      request: AdRequest(),
      listener: AdListener());
  @override
  Widget build(BuildContext context) {
    ad.load();
    return Stack(
      children: [
        Column(children: [
          AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.face_rounded,
                  color: Colors.yellow.shade900,
                  size: 24,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('廣告', style: TextStyle(fontSize: 14)),
                Text(
                  '廣告小天使',
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
          SizedBox(
            width: 320,
            height: 270,
            child: Center(
              child: AdWidget(ad: ad),
            ),
          ),
        ]),
      ],
    );
  }
}
