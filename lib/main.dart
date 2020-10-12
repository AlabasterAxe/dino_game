import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cactus.dart';
import 'cloud.dart';
import 'constants.dart';
import 'dino.dart';
import 'game-object.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
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
  }

  void _update() {
    if (!worldController.isAnimating) {
      return;
    }

    double elapsedSeconds =
        ((worldController.lastElapsedDuration.inMilliseconds -
                lastUpdateCall.inMilliseconds) /
            1000);

    dino.update(lastUpdateCall, worldController.lastElapsedDuration);
    runDistance = max(runDistance + runSpeed * elapsedSeconds, 0);
    runSpeed += RUN_SPEED_ACC_PPSPS * elapsedSeconds;

    Size screenSize = MediaQuery.of(context).size;

    for (GameObject obstacle in obstacles) {
      Rect obstacleRect = obstacle.getRect(screenSize, runDistance);
      Rect dinoRect = dino.getRect(screenSize, runDistance);
      if (dinoRect.deflate(15).overlaps(obstacleRect.deflate(15))) {
        _die();
      }
      if (obstacleRect.right < 0) {
        setState(() {
          obstacles.remove(obstacle);
          if (runDistance < 1000 || rand.nextDouble() > .5) {
            obstacles.add(Cactus(
                location: Offset(runDistance + rand.nextInt(100) + 50, 0)));
          } else {
            obstacles.add(Ptera(
                location: Offset(runDistance + rand.nextInt(100) + 100,
                    rand.nextInt(100).toDouble())));
          }
        });
      }
      obstacle.update(lastUpdateCall, worldController.lastElapsedDuration);
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
      obstacles = [
        Cactus(location: Offset(200, 0)),
      ];

      clouds = [
        Cloud(location: Offset(10, 0)),
        Cloud(location: Offset(200, 0)),
        Cloud(location: Offset(500, 0)),
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
    List<Widget> children = [
      AnimatedBuilder(
          animation: worldController,
          child: Image.asset(
            "assets/images/scenery.png",
            fit: BoxFit.cover,
          ),
          builder: (context, child) {
            return Positioned(
              bottom: screenSize.height / 3,
              left: -((runDistance * 10) % 2400),
              height: 20,
              child: child,
            );
          }),
      AnimatedBuilder(
          animation: worldController,
          child: Image.asset(
            "assets/images/scenery.png",
            fit: BoxFit.cover,
          ),
          builder: (context, child) {
            return Positioned(
              bottom: screenSize.height / 3,
              left: -((runDistance * 10) % 2400) + 2400 - screenSize.width,
              height: 20,
              child: child,
            );
          }),
      AnimatedBuilder(
          animation: worldController,
          builder: (context, child) {
            return Positioned(
              right: 0,
              left: 0,
              top: 0,
              height: screenSize.height / 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("${runDistance.floor()}",
                      style: GoogleFonts.vt323(fontSize: 36)),
                ],
              ),
            );
          }),
    ];
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

    if (dino.state == DinoState.dead) {
      children.add(Align(
        alignment: Alignment(0, -.5),
        child: Text("GAME OVER", style: GoogleFonts.vt323(fontSize: 48)),
      ));
    }

    children.add(Positioned(
        bottom: 20,
        left: 40,
        right: 40,
        height: screenSize.height / 4,
        child: GestureDetector(
            onTapDown: (_) {
              if (dino.state != DinoState.dead) {
                _jump();
              } else if (canReset) {
                resetStarted = true;
              }
            },
            onTapUp: (_) {
              if (dino.state != DinoState.dead) {
                dino.releaseJump();
              } else if (canReset && resetStarted) {
                _reset();
              }
            },
            child: InkWell(
              child: Ink(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(_buttonText(),
                          style: GoogleFonts.vt323(fontSize: 48)))),
            ))));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
          alignment: Alignment.center,
          children: children,
        ),
    );
  }
}
