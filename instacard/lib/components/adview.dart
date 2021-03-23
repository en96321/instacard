import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instacard/common/tool.dart';

class RewardAdWidget extends StatefulWidget {
  RewardAdWidget({Key key}) : super(key: key);

  @override
  _RewardAdWidgetState createState() => _RewardAdWidgetState();
}

class _RewardAdWidgetState extends State<RewardAdWidget> {
  // 廣告
  RewardedAd myRewarded;
  double hp = 0;
  @override
  void initState() {
    myRewarded = RewardedAd(
      adUnitId: Tool().getRewardAdUintId(),
      request: AdRequest(),
      listener: AdListener(
        onAdClosed: (Ad ad) {
          ad.dispose();
          ad.load();
        },
        onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
          setState(() {
            hp = 1.0;
          });
        },
      ),
    );
    myRewarded.load();
    super.initState();
  }

  @override
  void dispose() {
    if (myRewarded != null) myRewarded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Colors.grey.shade400,
          )),
      child: Column(
        children: [
          Center(
            child: Text(
              '看廣告補血',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          LinearProgressIndicator(
            minHeight: 16,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            value: hp,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Center(
            child: IconButton(
                iconSize: 48,
                icon: myRewarded != null
                    ? Icon(
                        Icons.redeem_rounded,
                        color: Colors.yellow.shade700,
                      )
                    : Container(),
                onPressed: () {
                  myRewarded.isLoaded().then((value) {
                    if (value) {
                      myRewarded.show();
                    } else {
                      final snackBar = SnackBar(
                        content: Text('請稍後在試',
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.black,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  });
                }),
          )
        ],
      ),
    );
  }
}
