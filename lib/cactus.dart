import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'dino-game-layout.dart';

List<Sprite> CACTI = [
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_group.png"
    ..imageWidth = 104
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_large_1.png"
    ..imageWidth = 50
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_large_2.png"
    ..imageWidth = 98
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_1.png"
    ..imageWidth = 34
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_2.png"
    ..imageWidth = 68
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_3.png"
    ..imageWidth = 107
    ..imageHeight = 70,
];

class Cactus extends GameObject {
  // this is a logical location which is translated to pixel coordinates
  final Offset location;
  final Sprite sprite;

  Cactus({this.location}) : sprite = CACTI[Random().nextInt(CACTI.length)];

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        (location.dx - runDistance) * 10,
        4 / 7 * screenSize.height - sprite.imageHeight - location.dy,
        sprite.imageWidth.toDouble(),
        sprite.imageHeight.toDouble());
  }

  @override
  Widget render() {
    return Image.asset(
      sprite.imagePath,
    );
  }
}
