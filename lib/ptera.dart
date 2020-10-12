import 'dino-game-layout.dart';
import 'dart:ui';

import 'package:flutter/widgets.dart';

List<Sprite> PTERA_FRAMES = [
  Sprite()
    ..imagePath = "assets/images/ptera/ptera_1.png"
    ..imageHeight = 80
    ..imageWidth = 92,
  Sprite()
    ..imagePath = "assets/images/ptera/ptera_2.png"
    ..imageHeight = 80
    ..imageWidth = 92,
];

class Ptera extends GameObject {
  // this is a logical location which is translated to pixel coordinates
  final Offset location;
  int frame = 0;

  Ptera({this.location});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        (location.dx - runDistance) * 10,
        4 / 7 * screenSize.height -
            PTERA_FRAMES[frame].imageHeight -
            location.dy,
        PTERA_FRAMES[frame].imageWidth.toDouble(),
        PTERA_FRAMES[frame].imageHeight.toDouble());
  }

  @override
  Widget render() {
    return Image.asset(
      PTERA_FRAMES[frame].imagePath,
      gaplessPlayback: true,
    );
  }

  @override
  void update(Duration lastUpdate, Duration elapsedTime) {
    frame = (elapsedTime.inMilliseconds / 200).floor() % 2;
  }
}
