import 'dart:ui';

class Sprite {
  String imagePath;
  int imageWidth;
  int imageHeight;
}

Sprite dino = Sprite()
  // basically a placeholder because we do the sprite animations separately
  ..imagePath = "dino/dino_1.png"
  ..imageWidth = 88
  ..imageHeight = 94;

class PlacedObstacle {
  Sprite obstacle;
  double location;
}

class DinoGameLayout {
  Rect dinoRectBaseline;
  Size screenSize;

  DinoGameLayout(Size screenSize) {
    this.dinoRectBaseline = Rect.fromLTWH(
        screenSize.width / 5,
        4 / 7 * screenSize.height - dino.imageHeight,
        dino.imageWidth.toDouble(),
        dino.imageHeight.toDouble());
    this.screenSize = screenSize;
  }

  Rect getDinoRect(double jumpOffset) {
    return dinoRectBaseline.shift(Offset(0, -jumpOffset));
  }

  Rect getObstacleRect(PlacedObstacle obstacle, double runDistance) {
    return Rect.fromLTWH(
        (obstacle.location - runDistance) * 10,
        4 / 7 * screenSize.height - obstacle.obstacle.imageHeight,
        dino.imageWidth.toDouble(),
        dino.imageHeight.toDouble());
  }
}
