import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dino-game-layout.dart';

void main() {
  runApp(MyApp());
}

List<Sprite> OBSTACLES = [
  Sprite()
    ..imagePath = "cacti_group.png"
    ..imageWidth = 104
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "cacti_large_1.png"
    ..imageWidth = 50
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "cacti_large_2.png"
    ..imageWidth = 98
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "cacti_small_1.png"
    ..imageWidth = 34
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "cacti_small_2.png"
    ..imageWidth = 68
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "cacti_small_3.png"
    ..imageWidth = 107
    ..imageHeight = 70,
];

const int GRAVITY_PPSPS = 100;

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum DinoState {
  running,
  jumping,
  dead,
  standing,
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController worldController;
  int dinoFrame = 1;
  double dinoY = 0;
  double dinodY = 0;
  int lastUpdateCallMillis = 0;

  List<PlacedObstacle> obstacles = [
    PlacedObstacle()
      ..location = 200
      ..obstacle = OBSTACLES[0],
    PlacedObstacle()
      ..location = 400
      ..obstacle = OBSTACLES[1],
    PlacedObstacle()
      ..location = 650
      ..obstacle = OBSTACLES[2]
  ];

  double runDistance = 0;
  DinoState dinoState = DinoState.standing;

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
    int currentElapsedTimeMillis =
        worldController.lastElapsedDuration.inMilliseconds;
    runDistance = (currentElapsedTimeMillis / 100).floorToDouble();

    DinoGameLayout layout = DinoGameLayout(MediaQuery.of(context).size);

    double elapsedSeconds =
        ((currentElapsedTimeMillis - lastUpdateCallMillis) / 1000);

    dinoY = max(dinoY + dinodY * elapsedSeconds, 0);
    if (dinoY > 0) {
      dinodY -= GRAVITY_PPSPS * elapsedSeconds;
    } else {
      dinoState = DinoState.running;
    }

    for (PlacedObstacle obstacle in obstacles) {
      Rect obstacleRect =
          layout.getObstacleRect(obstacle, runDistance).deflate(10);
      if (layout.getDinoRect(dinoY).deflate(10).overlaps(obstacleRect)) {
        dinoState = DinoState.dead;
      }
    }

    switch (dinoState) {
      case DinoState.dead:
        dinoFrame = 6;
        break;
      case DinoState.running:
        dinoFrame = (currentElapsedTimeMillis / 200).floor() % 2 + 3;
        break;
      case DinoState.jumping:
        dinoFrame = 1;
        break;
      case DinoState.standing:
        dinoFrame = 1;
        break;
    }

    lastUpdateCallMillis = currentElapsedTimeMillis;
  }

  void _run() {
    setState(() {
      dinoState = DinoState.running;
    });
  }

  void _die() {
    setState(() {
      dinoState = DinoState.dead;
    });
  }

  void _reset() {
    setState(() {
      runDistance = 0;
      dinoState = DinoState.standing;
      dinoFrame = 1;
      dinoY = 0.0;
      dinodY = 0.0;
    });
  }

  void _jump() {
    if (!worldController.isAnimating) {
      worldController.forward(from: 0);
    }
    if (dinoState == DinoState.running) {
      setState(() {
        dinodY = 100;
        dinoState = DinoState.jumping;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    DinoGameLayout layout = DinoGameLayout(screenSize);
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
              top: 0,
              child:
                  Text("$runDistance", style: GoogleFonts.vt323(fontSize: 36)),
            );
          }),
    ];
    for (PlacedObstacle obstacle in obstacles) {
      Rect obstacleRect = layout.getObstacleRect(obstacle, runDistance);
      children.add(
        AnimatedBuilder(
            animation: worldController,
            child: Image.asset(
              "assets/images/cacti/${obstacle.obstacle.imagePath}",
            ),
            builder: (context, child) {
              return Positioned(
                  top: obstacleRect.top,
                  left: obstacleRect.left,
                  width: obstacleRect.width,
                  height: obstacleRect.height,
                  child: child);
            }),
      );
    }
    children.add(AnimatedBuilder(
        animation: worldController,
        builder: (context, child) {
          Rect dinoRect = layout.getDinoRect(dinoY);
          return Positioned(
            left: dinoRect.left,
            top: dinoRect.top,
            width: dinoRect.width,
            height: dinoRect.height,
            child: Image.asset(
              "assets/images/dino/dino_${dinoFrame}.png",
              gaplessPlayback: true,
            ),
          );
        }));

    if (dinoState == DinoState.dead) {
      children.add(Align(
        alignment: Alignment.center,
        child: Text("GAME OVER", style: GoogleFonts.vt323(fontSize: 48)),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: children,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: dinoState == DinoState.dead ? _reset : _jump,
        tooltip: dinoState == DinoState.dead ? 'Reset' : 'Jump',
        child: Icon(
            dinoState == DinoState.dead ? Icons.refresh : Icons.arrow_upward),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
