import 'dart:ui';

import 'package:flutter/widgets.dart';

class Sprite {
  String imagePath;
  int imageWidth;
  int imageHeight;
}

abstract class GameObject {
  Widget render();
  Rect getRect(Size screenSize, double runDistance);
  void update(Duration lastUpdate, Duration elapsedTime) {}
}
