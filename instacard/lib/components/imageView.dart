import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// 圖片顯示器 (圖片網址)
class ImageView extends StatelessWidget {
  const ImageView({Key key, this.url}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(url),
          loadingBuilder: (context, event) {
            return Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? null
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            );
          },
        ),
      ),
    );
  }
}
