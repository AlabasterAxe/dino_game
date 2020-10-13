import 'dart:math';

import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

enum DinoState {
  running,
  jumping,
  dead,
  standing,
}

Sprite dino = Sprite()
  // basically a placeholder because we do the sprite animations separately
  ..imagePath = "dino/dino_1.png"
  ..imageWidth = 88
  ..imageHeight = 94;

class Dino extends GameObject {
  int frame = 1;
  DinoState state = DinoState.standing;
  bool jumpButtonHeld = false;
  double dispY = 0;
  double velY = 0;

  @override
  Widget render() {
    return Image.asset(
      "assets/images/dino/dino_$frame.png",
      gaplessPlayback: true,
    );
  }

  @override
  Rect getRect(Size screenSize, double _) {
    return Rect.fromLTWH(
        screenSize.width / 10,
        4 / 7 * screenSize.height - dino.imageHeight - dispY,
        dino.imageWidth.toDouble(),
        dino.imageHeight.toDouble());
  }

  void jump() {
    if (state != DinoState.jumping || jumpButtonHeld) {
      jumpButtonHeld = true;
      velY = 650;
    }
  }

  void releaseJump() {
    jumpButtonHeld = false;
  }

  void die() {
    state = DinoState.dead;
    frame = 6;
  }

  @override
  void update(Duration lastUpdate, Duration elapsedTime) {
    double elapsedSeconds =
        ((elapsedTime.inMilliseconds - lastUpdate.inMilliseconds) / 1000);

    dispY += velY * elapsedSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
    } else {
      velY -= GRAVITY_PPSPS * elapsedSeconds;
    }

    frame = (elapsedTime.inMilliseconds / 100).floor() % 2 + 3;
  }
}
