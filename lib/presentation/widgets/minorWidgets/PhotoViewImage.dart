import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../responsives/dimensions.dart';

class MyPhotoView extends StatelessWidget {
  var image;

  MyPhotoView({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: DM.screenHeight * 0.95,
        width: DM.screenWidth * 0.9,
        child: PhotoView(
            backgroundDecoration: BoxDecoration(
                color: Color.fromARGB(0, 255, 255, 255),
                borderRadius: BorderRadius.circular(DM.p10)),
            imageProvider: true
                ? NetworkImage(image.toString())
                : NetworkImage(image.toString())));
  }
}
