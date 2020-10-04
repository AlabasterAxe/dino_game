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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController dinoController;
  Animation<int> dinoFrame;
  Animation<double> dinoY;

  List<PlacedObstacle> obstacles = [
    PlacedObstacle()
      ..location = 200
      ..obstacle = OBSTACLES[0],
  ];

  double runDistance = 0;
  bool isRunning = false;
  bool isDead = false;

  Timer runningTimer;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _run() {
    if (dinoController != null) {
      dinoController.dispose();
    }
    setState(() {
      dinoController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 200));
      dinoController.repeat();

      dinoFrame = StepTween(begin: 3, end: 5).animate(dinoController);
      dinoY = AlwaysStoppedAnimation(0);
      isRunning = true;
      if (runningTimer == null) {
        runningTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
          setState(() {
            runDistance += 3;
          });
          DinoGameLayout layout = DinoGameLayout(MediaQuery.of(context).size);
          for (PlacedObstacle obstacle in obstacles) {
            Rect obstacleRect =
                layout.getObstacleRect(obstacle, runDistance).deflate(10);
            Rect dinoRect = layout.getDinoRect(dinoY.value);
            if (dinoRect.deflate(10).overlaps(obstacleRect)) {
              _die();
            } else {
              if (obstacleRect.right + 200 < dinoRect.left) {
                obstacles.remove(obstacle);

                final _random = new Random();
                obstacles.add(PlacedObstacle()
                  ..obstacle = OBSTACLES[_random.nextInt(OBSTACLES.length)]
                  ..location = runDistance + _random.nextInt(200) + 100.0);
              }
            }
          }
        });
      }
    });
  }

  void _die() {
    setState(() {
      runningTimer.cancel();
      dinoController.stop();
      dinoFrame = AlwaysStoppedAnimation(6);
      isRunning = false;
      isDead = true;
    });
  }

  void _reset() {
    setState(() {
      runDistance = 0;
      isRunning = false;
      isDead = false;
      dinoController = AnimationController(vsync: this);
      dinoFrame = AlwaysStoppedAnimation(1);
      dinoY = AlwaysStoppedAnimation(0.0);
      runningTimer = null;
    });
  }

  void _jump() {
    if (dinoController != null) {
      dinoController.dispose();
    }
    setState(() {
      dinoController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 400));
      dinoFrame = AlwaysStoppedAnimation(1);
      dinoY = Tween(begin: 0.0, end: 200.0)
          .chain(CurveTween(curve: Curves.easeOutQuad))
          .animate(dinoController);
      dinoController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          dinoController.reverse();
          dinoController.addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              _run();
            }
          });
        }
      });
      dinoController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    DinoGameLayout layout = DinoGameLayout(screenSize);
    List<Widget> children = [
      Positioned(
        bottom: screenSize.height / 3,
        left: -((runDistance * 10) % 2400),
        height: 20,
        child: Image.asset(
          "assets/images/scenery.png",
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        bottom: screenSize.height / 3,
        left: -((runDistance * 10) % 2400) + 2400 - screenSize.width,
        height: 20,
        child: Image.asset(
          "assets/images/scenery.png",
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        right: 0,
        top: 0,
        child: Text("$runDistance", style: GoogleFonts.vt323(fontSize: 36)),
      ),
    ];
    for (PlacedObstacle obstacle in obstacles) {
      Rect obstacleRect = layout.getObstacleRect(obstacle, runDistance);
      children.add(
        Positioned(
          top: obstacleRect.top,
          left: obstacleRect.left,
          width: obstacleRect.width,
          height: obstacleRect.height,
          child: Image.asset(
            "assets/images/cacti/${obstacle.obstacle.imagePath}",
          ),
        ),
      );
    }
    children.add(AnimatedBuilder(
        animation: dinoController,
        builder: (context, child) {
          Rect dinoRect = layout.getDinoRect(dinoY.value);
          return Positioned(
            left: dinoRect.left,
            top: dinoRect.top,
            width: dinoRect.width,
            height: dinoRect.height,
            child: Image.asset(
              "assets/images/dino/dino_${dinoFrame.value}.png",
              gaplessPlayback: true,
            ),
          );
        }));

    if (isDead) {
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
        onPressed: isDead ? _reset : _jump,
        tooltip: isDead ? 'Reset' : 'Jump',
        child: Icon(isDead ? Icons.refresh : Icons.arrow_upward),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
