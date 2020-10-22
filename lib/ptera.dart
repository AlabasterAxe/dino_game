import 'dart:ui';

import 'package:dino_game/constants.dart';
import 'package:flutter/widgets.dart';

import 'game-object.dart';
import 'sprite.dart';

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
  final Offset worldLocation;
  int frame = 0;

  Ptera({this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        (worldLocation.dx - runDistance) * WORLD_TO_PIXEL_RATIO,
        4 / 7 * screenSize.height -
            PTERA_FRAMES[frame].imageHeight -
            worldLocation.dy,
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
