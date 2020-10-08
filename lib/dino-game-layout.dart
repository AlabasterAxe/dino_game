import 'dart:ui';

class Sprite {
  String imagePath;
  int imageWidth;
  int imageHeight;
}

class GameObject {
  bool collidable;
  List<Sprite> frames;
  double frequency;
}

Sprite dino = Sprite()
  // basically a placeholder because we do the sprite animations separately
  ..imagePath = "dino/dino_1.png"
  ..imageWidth = 88
  ..imageHeight = 94;

class PlacedObject {
  GameObject object;
  Offset location;
  Offset velocity;
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

  Rect getObstacleRect(PlacedObject obstacle, double runDistance) {
    return Rect.fromLTWH(
        (obstacle.location.dx - runDistance) * 10,
        4 / 7 * screenSize.height -
            obstacle.object.frames[0].imageHeight -
            obstacle.location.dy,
        obstacle.object.frames[0].imageWidth.toDouble(),
        obstacle.object.frames[0].imageHeight.toDouble());
  }
}
