import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cactus.dart';
import 'cloud.dart';
import 'constants.dart';
import 'dino.dart';
import 'game-object.dart';
import 'ground.dart';
import 'ptera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController worldController;
  Duration lastUpdateCall = Duration();
  Random rand = Random();

  List<GameObject> obstacles;

  List<Ground> ground;

  List<Cloud> clouds;

  Dino dino = Dino();
  double runDistance = 0;
  double runSpeed = 30;
  double best = 0;

  // this is used to debounce jump clicks that occur right before the user dies
  bool canReset = false;
  bool resetStarted = false;

  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: Duration(days: 99));

    worldController.addListener(_update);

    _reset();
    worldController.forward();
  }

  void _update() {
    double elapsedSeconds =
        ((worldController.lastElapsedDuration.inMilliseconds -
                lastUpdateCall.inMilliseconds) /
            1000);

    dino.update(lastUpdateCall, worldController.lastElapsedDuration);
    runDistance = max(runDistance + runSpeed * elapsedSeconds, 0);
    runSpeed += RUN_SPEED_ACC_PPSPS * elapsedSeconds;

    Size screenSize = MediaQuery.of(context).size;

    Rect dinoRect = dino.getRect(screenSize, runDistance);
    for (GameObject obstacle in obstacles) {
      Rect obstacleRect = obstacle.getRect(screenSize, runDistance);

      if (dinoRect.deflate(15).overlaps(obstacleRect.deflate(15))) {
        _die();
      }
      if (obstacleRect.right < 0) {
        setState(() {
          obstacles.remove(obstacle);
          obstacles.add(Cactus(
              worldLocation: Offset(runDistance + rand.nextInt(100) + 50, 0)));
        });
      }
      obstacle.update(lastUpdateCall, worldController.lastElapsedDuration);
    }

    for (Ground groundlet in ground) {
      if (groundlet.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          ground.remove(groundlet);
          ground.add(Ground(
              worldLocation: Offset(
                  ground.last.worldLocation.dx +
                      groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO,
                  0)));
        });
      }
    }

    for (Cloud cloud in clouds) {
      if (cloud.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          clouds.remove(cloud);
          clouds.add(Cloud(
              location: Offset(
                  clouds.last.location.dx + rand.nextInt(100) + 100,
                  rand.nextInt(100) - 10.0)));
        });
      }
    }

    lastUpdateCall = worldController.lastElapsedDuration;
  }

  void _die() {
    setState(() {
      worldController.stop();
      dino.die();
      Timer(Duration(milliseconds: 100), () {
        canReset = true;
      });
    });
  }

  void _reset() {
    setState(() {
      if (runDistance > best) {
        best = runDistance;
      }
      runDistance = 0;
      runSpeed = 30;
      obstacles = [
        Cactus(worldLocation: Offset(200, 0)),
      ];

      clouds = [
        Cloud(location: Offset(10, 0)),
        Cloud(location: Offset(200, 0)),
        Cloud(location: Offset(500, 0)),
      ];
      ground = [
        Ground(worldLocation: Offset(0, 0)),
        Ground(
            worldLocation:
                Offset(groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO, 0))
      ];
      dino = Dino();
      lastUpdateCall = Duration();
      canReset = false;
      resetStarted = false;
    });
  }

  void _jump() {
    if ([DinoState.standing, DinoState.running].contains(dino.state)) {
      if (!worldController.isAnimating) {
        worldController.forward(from: 0);
      }
      setState(() {
        dino.jump();
        Timer(Duration(milliseconds: 100), dino.releaseJump);
      });
    }
  }

  String _buttonText() {
    switch (dino.state) {
      case DinoState.running:
      case DinoState.jumping:
        return "Jump";
      case DinoState.dead:
        return "Reset";
      case DinoState.standing:
        return "Start";
      default:
        return "Jump";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];
    for (Cloud cloud in clouds) {
      children.add(
        AnimatedBuilder(
            animation: worldController,
            child: cloud.render(),
            builder: (context, child) {
              Rect cloudRect = cloud.getRect(screenSize, runDistance);
              return Positioned(
                  top: cloudRect.top,
                  left: cloudRect.left,
                  width: cloudRect.width,
                  height: cloudRect.height,
                  child: child);
            }),
      );
    }
    for (Ground groundlet in ground) {
      children.add(
        AnimatedBuilder(
            animation: worldController,
            child: groundlet.render(),
            builder: (context, child) {
              Rect groundRect = groundlet.getRect(screenSize, runDistance);
              return Positioned(
                  top: groundRect.top,
                  left: groundRect.left,
                  width: groundRect.width,
                  height: groundRect.height,
                  child: child);
            }),
      );
    }
    for (GameObject obstacle in obstacles) {
      children.add(
        AnimatedBuilder(
            animation: worldController,
            builder: (context, child) {
              Rect obstacleRect = obstacle.getRect(screenSize, runDistance);
              return Positioned(
                  top: obstacleRect.top,
                  left: obstacleRect.left,
                  width: obstacleRect.width,
                  height: obstacleRect.height,
                  child: obstacle.render());
            }),
      );
    }
    children.add(AnimatedBuilder(
        animation: worldController,
        builder: (context, child) {
          Rect dinoRect = dino.getRect(screenSize, runDistance);
          return Positioned(
            left: dinoRect.left,
            top: dinoRect.top,
            width: dinoRect.width,
            height: dinoRect.height,
            child: dino.render(),
          );
        }));

    // if (dino.state == DinoState.dead) {
    //   children.add(Align(
    //     alignment: Alignment(0, -.5),
    //     child: Text("GAME OVER", style: GoogleFonts.vt323(fontSize: 48)),
    //   ));
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          dino.jump();
        },
        child: Stack(
          alignment: Alignment.center,
          children: children,
        ),
      ),
    );
  }
}
