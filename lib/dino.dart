import 'dart:math';

import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'dino-game-layout.dart';

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
  double displacementY = 0;
  double velocityY = 0;
  bool jumpButtonHeld = false;

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
        4 / 7 * screenSize.height - dino.imageHeight - displacementY,
        dino.imageWidth.toDouble(),
        dino.imageHeight.toDouble());
  }

  void jump() {
    jumpButtonHeld = true;
    velocityY = 650;
    state = DinoState.jumping;

    // TODO: Do i need this?
    displacementY = .01;
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

    displacementY = max(displacementY + velocityY * elapsedSeconds, 0);
    if (displacementY > 0 && !jumpButtonHeld) {
      velocityY -= GRAVITY_PPSPS * elapsedSeconds;
    }
    if (displacementY <= 0) {
      state = DinoState.running;
    }

    switch (state) {
      case DinoState.dead:
        frame = 6;
        break;
      case DinoState.running:
        frame = (elapsedTime.inMilliseconds / 100).floor() % 2 + 3;
        break;
      case DinoState.jumping:
        frame = 1;
        break;
      case DinoState.standing:
        frame = 1;
        break;
    }
  }
}
