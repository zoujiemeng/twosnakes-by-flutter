// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';
import 'package:twosnakes/game_state.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

Future main() async {
  OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => GameState()),
      ],
      child: Consumer<GameState>(
        builder: (context, gameState, _) {
          gameState = Provider.of<GameState>(context);
          return MaterialApp(
            title: 'Gluttonous Snake',
            theme: ThemeData(
              scaffoldBackgroundColor: Color(gameState.appBkColor),
            ),
            home: SnakeHome(),
          );
        },
      ),
    );
  }
}

class SnakeHomeState extends State<SnakeHome>
    with SingleTickerProviderStateMixin {
  //final Color _controllerBK = Colors.black26;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    //_blockNum = 50;
    controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(controller);
    //controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final gameState = Provider.of<GameState>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildController(
              width,
              height,
              'left',
              Color(gameState.leftPlayerColor),
              Color(gameState.controllerShadowColor)),
          _buildMainPanel(context, width, height),
          Column(
            children: <Widget>[
              _scoreBoard(),
              _buildController(
                  width,
                  height,
                  'right',
                  Color(gameState.rightPlayerColor),
                  Color(gameState.controllerShadowColor)),
            ],
          ),
        ],
      ),
      endDrawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.settings_applications),
              title: Text('Color Options'),
            ),
            Divider(
              color: Colors.black,
              height: 5.0,
            ),
            Card(
              child: ListTile(
                leading: colorOptionLeading(gameState.appBkColor, 30.0),
                title: Text('background color'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.optionsAppBkColor(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: colorOptionLeading(gameState.leftPlayerColor, 30.0),
                title: Text('left player color'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.optionsLeftColor(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: colorOptionLeading(gameState.rightPlayerColor, 30.0),
                title: Text('right player color'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.optionsRightColor(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading:
                    colorOptionLeading(gameState.brickOnePlayerColor, 30.0),
                title: Text('snake color(1 player)'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.optionsOnePlayerColor(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: colorOptionLeading(gameState.scoreBoardColor, 30.0),
                title: Text('score board color(1 player)'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.optionsScoreBoardColor(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: colorOptionLeading(gameState.foodColor, 30.0),
                title: Text('food color'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.optionsFoodColor(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.save,
                  size: 30,
                ),
                title: Text('save color plan'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.saveColorPlan(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.restore,
                  size: 30,
                ),
                title: Text('reset color plan'),
                onTap: () {
                  Navigator.pop(context);
                  gameState.resetColorPlan(context);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButtonOnclick(context),
    );
  }

  Container _scoreBoard() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final gameState = Provider.of<GameState>(context);
    if (gameState.playerNum == 1) {
      return Container(
        height: height / 5,
        width: width / 6,
        margin: EdgeInsets.fromLTRB(0.0, height * 0.02, 0.0, height * 0.03),
        transform: Matrix4.rotationZ(0.1),
        decoration: BoxDecoration(
            color: Color(gameState.scoreBoardColor),
            border: Border.all(
              color: Colors.black87,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(20.0)),
        child: Stack(
          children: <Widget>[
            // Positioned(
            //     left: 0.0, top: 0.0, child: Icon(Icons.fiber_new)),
            Center(
                child: Text(
                    'high score: ${gameState.highScore}\nScore: ${gameState.score}')),
          ],
        ),
      );
    } else {
      return Container(
        height: height / 5,
        width: width / 6,
        margin: EdgeInsets.fromLTRB(0.0, height * 0.02, 0.0, height * 0.03),
      );
    }
  }

  Container colorOptionLeading(int colorValue, double size) {
    return Container(
        //color: Color(colorValue),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
        ));
  }

  SpeedDial floatingActionButtonOnclick(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    bool initFlag = gameState.initFlag;
    if (initFlag) {
      return SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.6,
        onOpen: () {
          gameState.menuOpen();
        },
        onClose: () {
          gameState.menuClose();
        },
        tooltip: 'SpeedDialInitial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.settings),
            backgroundColor: Colors.yellow,
            label: 'Options',
            labelStyle: TextStyle(fontSize: 20.0),
            onTap: () {
              gameState.setMenuFlag(false);
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.exit_to_app),
            backgroundColor: Colors.red,
            label: 'Exit Game',
            labelStyle: TextStyle(fontSize: 20.0),
            onTap: () {
              gameState.menuExit(context);
            },
          ),
        ],
      );
    } else {
      return SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.pause_play,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: !gameState.initFlag,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.6,
        onOpen: () {
          gameState.pauseGame();
        },
        onClose: () {
          gameState.playGame(context);
        },
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.settings),
            backgroundColor: Colors.yellow,
            label: 'Options',
            labelStyle: TextStyle(fontSize: 20.0),
            onTap: () {
              gameState.setPlayFlag(false);
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
          SpeedDialChild(
              child: Icon(Icons.redo),
              backgroundColor: Colors.green,
              label: 'Quick Restart',
              labelStyle: TextStyle(fontSize: 20.0),
              onTap: () {
                gameState.menuQuickRestart(context);
              }),
          SpeedDialChild(
            child: Icon(Icons.refresh),
            backgroundColor: Colors.blue,
            label: 'Restart',
            labelStyle: TextStyle(fontSize: 20.0),
            onTap: () {
              gameState.menuRestart(context);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.exit_to_app),
            backgroundColor: Colors.red,
            label: 'Exit Game',
            labelStyle: TextStyle(fontSize: 20.0),
            onTap: () {
              gameState.menuExit(context);
            },
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  StatefulWidget _buildMainPanel(
      BuildContext context, double width, double height) {
    double tmp = width - height;
    double size = tmp > height ? height : tmp;
    size -= 5.0;
    final gameState = Provider.of<GameState>(context);
    int _blockNum;
    if (gameState.initFlag) {
      _blockNum = gameState.initSize;
    } else {
      _blockNum = gameState.mapSize;
    }
    double brickSize = size / _blockNum;
    return InkWell(
      onTap: () {
        gameState.setConfig(context);
      },
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.only(top: 1.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(gameState.controllerShadowColor),
              blurRadius: 0.0, // has the effect of softening the shadow
              spreadRadius: 0.0, // has the effect of extending the shadow
              offset: Offset(
                1.0, // horizontal, move right
                1.0, // vertical, move down
              ),
            )
          ],
        ),
        child: Column(
          children: gameState.data.map((list) {
            return Row(
              children: list.map((b) {
                return _brick(Color(b), brickSize);
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  SizedBox _brick(Color color, double width) {
    return SizedBox.fromSize(
      size: Size(width, width),
      child: Container(
        margin: EdgeInsets.all(0.05 * width),
        padding: EdgeInsets.all(0.1 * width),
        decoration: BoxDecoration(
            border: Border.all(width: 0.10 * width, color: color)),
        child: Container(
          color: color,
        ),
      ),
    );
  }

  Container _circularButton(double size, IconData icon, Color bkColor,
      Color shadowColor, EdgeInsets edgeInset, String player) {
    final gameState = Provider.of<GameState>(context);
    return Container(
      width: size,
      height: size,
      margin: edgeInset,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 0.0, // has the effect of softening the shadow
            spreadRadius: 0.0, // has the effect of extending the shadow
            offset: Offset(
              1.0, // horizontal, move right 10
              4.0, // vertical, move down 10
            ),
          )
        ],
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: RaisedButton(
        shape: CircleBorder(),
        color: bkColor,
        child: Center(
          child: Icon(
            icon,
            size: 30.0,
          ),
        ),
        onPressed: () {
          gameState.clickButton(icon, player);
        },
      ),
    );
  }

  Container _buildController(double width, double height, String player,
      Color buttonColor, Color shadowColor) {
    final bkColor = Colors.black26;
    final buttonBKColor = buttonColor;
    final buttonSDColor = shadowColor;
    final containerSize = height / 2;
    final buttonSize = containerSize / 3.2;
    return Container(
      width: containerSize,
      height: containerSize,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: bkColor,
            borderRadius: BorderRadius.circular(containerSize / 2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _circularButton(buttonSize, Icons.arrow_left, buttonBKColor,
                buttonSDColor, EdgeInsets.only(left: 5.0), player),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circularButton(buttonSize, Icons.arrow_drop_up, buttonBKColor,
                    buttonSDColor, EdgeInsets.only(top: 7.0), player),
                _circularButton(
                    buttonSize,
                    Icons.arrow_drop_down,
                    buttonBKColor,
                    buttonSDColor,
                    EdgeInsets.only(bottom: 9.0),
                    player),
              ],
            ),
            _circularButton(buttonSize, Icons.arrow_right, buttonBKColor,
                buttonSDColor, EdgeInsets.only(right: 5.0), player),
          ],
        ),
      ),
    );
  }
}

class SnakeHome extends StatefulWidget {
  @override
  SnakeHomeState createState() => SnakeHomeState();
}
