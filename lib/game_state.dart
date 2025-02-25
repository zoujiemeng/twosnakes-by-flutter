import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  int _playerNum = 1;
  int _mapSize = 50;
  int _speed = 500;
  int _initSize = 50;

  bool _playFlag = false;
  bool _initFlag = true;
  bool _menuFlag = false;
  bool _vibration = true;
  bool _launchIconFlag = false;
  List<List<int>> _data = [];
  Queue _queue1 = Queue();
  Queue _queue2 = Queue();
  List<int> _direction1 = [];
  List<int> _direction2 = [];
  List _gameMapList = [];
  late Timer _timer;
  List<int> _food = [];
  int _step = 0;
  // from default.json
  int _appBkColor = 0xFFB2FF59;
  int _brickBkColor = 0x1F000000;
  int _leftPlayerColor = 0xFFFFEB3B;
  int _rightPlayerColor = 0xFF69F0AE;
  int _controllerShadowColor = 0x61000000;
  int _brickOnePlayerColor = 0xDD000000;
  int _scoreBoardColor = 0xFFF48FB1;
  int _foodColor = 0xDD000000;
  // score
  int _highScore = 0;
  int _score = 0;
  final _moveMap = {
    'UP': [-1, 0],
    'DOWN': [1, 0],
    'LEFT': [0, -1],
    'RIGHT': [0, 1]
  };

  var _modeTitle = 'Please choose game mode';
  var _modeOptions = {
    '♂️traditional(1 player)': 1,
    '⚣battle(2 player)': 2,
  };

  var _sizeTitle = 'Please choose map size';
  var _sizeOptions = {
    '⛩️small': 30,
    '🗻medium': 40,
    '🗾large': 50,
  };

  var _speedTitle = 'Please choose game difficulty';
  var _speedOptions = {
    '😄Easy': 250,
    '🙂Normal': 200,
    '🙃Hard': 120,
  };

  int get playerNum => _playerNum;
  int get mapSize => _mapSize;
  int get initSize => _initSize;
  int get speed => _speed;
  bool get initFlag => _initFlag;

  int get appBkColor => _appBkColor;
  int get brickBkColor => _brickBkColor;
  int get leftPlayerColor => _leftPlayerColor;
  int get rightPlayerColor => _rightPlayerColor;
  int get controllerShadowColor => _controllerShadowColor;
  int get brickOnePlayerColor => _brickOnePlayerColor;
  int get scoreBoardColor => _scoreBoardColor;
  int get foodColor => _foodColor;

  int get highScore => _highScore;
  int get score => _score;

  void setAppBkColor(Color color) => _appBkColor = color.value;
  void setPlayFlag(bool flag) => _playFlag = flag;
  void setMenuFlag(bool flag) => _menuFlag = flag;

  List<List<int>> get data => _data;

  GameState() {
    _initSettings();
    if (_launchIconFlag){
      _initSize = 21;
      _generateLaunchIcon();
    }
    else{
      _initGame();
    }
    
  }

  void _initSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _appBkColor = prefs.getInt('appBk') ?? _appBkColor;
    _brickBkColor = prefs.getInt('brickBk') ?? _brickBkColor;
    _leftPlayerColor = prefs.getInt('leftPlayer') ?? _leftPlayerColor;
    _rightPlayerColor = prefs.getInt('rightPlayer') ?? _rightPlayerColor;
    _controllerShadowColor =
        prefs.getInt('controllerShadow') ?? _controllerShadowColor;
    _brickOnePlayerColor =
        prefs.getInt('brickOnePlayer') ?? _brickOnePlayerColor;
    _scoreBoardColor = prefs.getInt('scoreBoard') ?? _scoreBoardColor;
    _foodColor = prefs.getInt('food') ?? _foodColor;

    _highScore = prefs.getInt('highScore') ?? _highScore;
  }

  void saveColorPlan(BuildContext context) async {
    _timer.cancel();
    var saveTitle = 'Do you want to save your color plan?';
    var saveOptions = {'NO❌': 0, 'YES✔️': 1};
    var confirm = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, saveTitle, saveOptions);
        });
    if (saveOptions[confirm] == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('appBk', _appBkColor);
      prefs.setInt('brickBk', _brickBkColor);
      prefs.setInt('leftPlayer', _leftPlayerColor);
      prefs.setInt('rightPlayer', _rightPlayerColor);
      prefs.setInt('controllerShadow', _controllerShadowColor);
      prefs.setInt('brickOnePlayer', _brickOnePlayerColor);
      prefs.setInt('scoreBoard', _scoreBoardColor);
      prefs.setInt('food', _foodColor);
      if (context.mounted) {
        await showDialog(
            context: context,
            builder: (context) {
              return configDialog(
                  context, 'succeed in saving color plan!😆', {'Confirm✔️': 1});
            });
      }
    }
    if (_initFlag) {
      _initGame();
    } else {
      if (context.mounted) {
        _updateState(context);
      }
    }
  }

  void resetColorPlan(BuildContext context) async {
    _timer.cancel();
    var saveTitle = 'Are you sure to reset color plan to default?';
    var saveOptions = {'NO❌': 0, 'YES✔️': 1};
    var confirm = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, saveTitle, saveOptions);
        });
    if (saveOptions[confirm] == 1) {
      var jsonString = await rootBundle.loadString('assets/cfg/default.json');
      var config = jsonDecode(jsonString);
      _appBkColor = int.parse(config['appBk']);
      _leftPlayerColor = int.parse(config['leftPlayer']);
      _rightPlayerColor = int.parse(config['rightPlayer']);
      _brickOnePlayerColor = int.parse(config['brickOnePlayer']);
      _scoreBoardColor = int.parse(config['scoreBoard']);
      _foodColor = int.parse(config['food']);
      notifyListeners();
      if (context.mounted) {
        await showDialog(
            context: context,
            builder: (context) {
              return configDialog(context, 'succeed in resetting color plan!😆',
                  {'Confirm✔️': 1});
            });
      }
    }
    if (_initFlag) {
      _initGame();
    } else {
      if (context.mounted) {
        _updateState(context);
      }
    }
  }

  void _zeroData(int size) {
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        _data[i][j] = _brickBkColor;
      }
    }
  }

  void _initGame() {
    _step = 0;

    _data = List.generate(_initSize, (_) => List.generate(_initSize, (_) => 0));
    _zeroData(_initSize);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      _step = (_step + 1) % 5;
      var colorList = [
        0x42000000,
        0x61000000,
        0x8A000000,
        0xDD000000,
        0xFF000000
      ];
      _setSTART(colorList[_step]);

      notifyListeners();
    });

    _initFlag = true;
  }

  void _setSTART(int state) {
    var dotS = [
      [0, 1],
      [0, 2],
      [1, 0],
      [1, 3],
      [2, 0],
      [3, 1],
      [3, 2],
      [4, 3],
      [5, 0],
      [5, 3],
      [6, 1],
      [6, 2]
    ];
    var dotT = [
      [0, 0],
      [0, 1],
      [0, 2],
      [0, 3],
      [0, 4],
      [1, 2],
      [2, 2],
      [3, 2],
      [4, 2],
      [5, 2],
      [6, 2]
    ];
    var dotA = [
      [0, 2],
      [1, 1],
      [1, 3],
      [2, 0],
      [2, 4],
      [3, 0],
      [3, 4],
      [4, 0],
      [4, 1],
      [4, 2],
      [4, 3],
      [4, 4],
      [5, 0],
      [5, 4],
      [6, 0],
      [6, 4]
    ];
    var dotR = [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 0],
      [1, 3],
      [2, 0],
      [2, 3],
      [3, 0],
      [3, 1],
      [3, 2],
      [4, 0],
      [4, 2],
      [5, 0],
      [5, 3],
      [6, 0],
      [6, 4]
    ];
    var baseOffset = 8;
    _setChar(dotS, [20, baseOffset], state);
    _setChar(dotT, [20, baseOffset += 7], state);
    _setChar(dotA, [20, baseOffset += 7], state);
    _setChar(dotR, [20, baseOffset += 8], state);
    _setChar(dotT, [20, baseOffset += 7], state);
  }

  void _setChar(List<List<int>> dot, List<int> offset, int state) {
    for (var i in dot) {
      _data[i[0] + offset[0]][i[1] + offset[1]] = state;
    }
  }

  void _setStartPos(Queue q, List headPos, List direction, int color) {
    q.clear();
    var x = headPos[0];
    var y = headPos[1];
    for (var i = 0; i < 3; i++) {
      _data[x][y] = color;
      q.add([x, y]);
      x = x + direction[0];
      y = y + direction[1];
    }
  }

  void _startGame(BuildContext context) {
    _timer.cancel();
    _data = List.generate(_mapSize, (_) => List.generate(_mapSize, (_) => 0));
    _zeroData(_mapSize);
    switch (_playerNum) {
      case 1:
        var h = [_mapSize ~/ 2, _mapSize ~/ 2];
        _direction1 = _moveMap['RIGHT']!;
        _setStartPos(_queue1, h, _moveMap['LEFT']!, _brickOnePlayerColor);
        break;
      case 2:
        var h1 = [_mapSize ~/ 4, _mapSize ~/ 2];
        _direction1 = _moveMap['RIGHT']!;
        _setStartPos(_queue1, h1, _moveMap['LEFT']!, _leftPlayerColor);
        var h2 = [_mapSize * 3 ~/ 4, _mapSize ~/ 2];
        _direction2 = _moveMap['LEFT']!;
        _setStartPos(_queue2, h2, _moveMap['RIGHT']!, _rightPlayerColor);
        break;
      default:
    }
    _score = 0;
    _gameMapList =
        List<int>.generate(_mapSize * _mapSize, (int index) => index);
    _gameMapList.shuffle();
    _createFood();
    _initFlag = false;
    notifyListeners();
    _updateState(context);
  }

  void _createFood() {
    switch (_playerNum) {
      case 1:
        for (var i in _gameMapList) {
          var x = i ~/ _mapSize;
          var y = i % _mapSize;
          if (_data[x][y] == _brickBkColor) {
            _food = [x, y];
            _data[x][y] = _foodColor;
            break;
          }
        }
        break;
      case 2:
        for (var i in _gameMapList) {
          var x = i ~/ _mapSize;
          var y = i % _mapSize;
          var h1 = _queue1.first;
          var h2 = _queue2.first;
          if (_data[x][y] == _brickBkColor &&
              ((x - h1[0]).abs() + (y - h1[1]).abs()) -
                      ((x - h2[0]).abs() + (y - h2[1]).abs()).abs() <
                  4) {
            _food = [x, y];
            _data[x][y] = _foodColor;
            break;
          }
        }
        break;
      default:
    }
  }

  void _gameOverTwoPlayer(BuildContext context, String winner) {
    switch (winner) {
      case 'draw':
        _gameOver(context, 'draw! ⚖️');
        break;
      case 'left':
        _gameOver(context, 'left player wins!🎉');
        break;
      case 'right':
        _gameOver(context, 'right player wins!🎉');
        break;
      default:
    }
  }

  void _gameOver(BuildContext context, String title) async {
    var overOptions = {'Return': 0, 'Restart': 1, 'Quick Restart': 2};
    var option = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, title, overOptions);
        });
    switch (option) {
      case 'Return':
        //_initGame();
        //notifyListeners();
        break;
      case 'Restart':
        if (context.mounted) {
          setConfig(context);
        }
        break;
      case 'Quick Restart':
        if (context.mounted) {
          _startGame(context);
        }
        break;
      default:
    }
  }

  bool _checkCollisionTwoPlayer(int x, int y) {
    if (x < 0 ||
        x > _mapSize - 1 ||
        y < 0 ||
        y > _mapSize - 1 ||
        _data[x][y] == _leftPlayerColor ||
        _data[x][y] == _rightPlayerColor) {
      return true;
    }
    return false;
  }

  void _updateState(BuildContext context) {
    _step = 0;
    _timer =
        Timer.periodic(Duration(milliseconds: _speed), (Timer timer) async {
      _step = (_step + 1) % 5;
      switch (_playerNum) {
        case 1:
          var header = _queue1.first;
          var futureX = header[0] + _direction1[0];
          var futureY = header[1] + _direction1[1];
          var last = _queue1.last;
          _data[last[0]][last[1]] = _brickBkColor;
          if (futureX == _food[0] && futureY == _food[1]) {
            _queue1.addFirst([futureX, futureY]);
            _data[futureX][futureY] = _brickOnePlayerColor;
            _data[last[0]][last[1]] = _brickOnePlayerColor;
            _score++;
            _createFood();
          } else if (futureX < 0 ||
              futureX > _mapSize - 1 ||
              futureY < 0 ||
              futureY > _mapSize - 1 ||
              _data[futureX][futureY] == _brickOnePlayerColor) {
            _timer.cancel();
            if (_score > _highScore) {
              _highScore = _score;
              notifyListeners();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('highScore', _highScore);
              if (context.mounted) {
                _gameOver(context, 'NEW RECORD!🎉\n 🆕high score: $_highScore');
              }
            } else {
              _gameOver(context, 'GAME OVER 😂');
            }

            return;
          } else {
            _queue1.addFirst([futureX, futureY]);
            _data[futureX][futureY] = _brickOnePlayerColor;
            _queue1.removeLast();
          }
          break;
        case 2:
          var header1 = _queue1.first;
          var futureX1 = header1[0] + _direction1[0];
          var futureY1 = header1[1] + _direction1[1];
          var last1 = _queue1.last;
          _data[last1[0]][last1[1]] = _brickBkColor;
          var header2 = _queue2.first;
          var futureX2 = header2[0] + _direction2[0];
          var futureY2 = header2[1] + _direction2[1];
          var last2 = _queue2.last;
          _data[last2[0]][last2[1]] = _brickBkColor;
          bool leftCollision = _checkCollisionTwoPlayer(futureX1, futureY1);
          bool rightCollision = _checkCollisionTwoPlayer(futureX2, futureY2);
          if (futureX1 == futureX2 && futureY1 == futureY2) {
            _timer.cancel();
            _gameOverTwoPlayer(context, 'draw');
            return;
          } else if (leftCollision && rightCollision) {
            _timer.cancel();
            _gameOverTwoPlayer(context, 'draw');
            return;
          } else if (leftCollision && !rightCollision) {
            _timer.cancel();
            _gameOverTwoPlayer(context, 'right');
            return;
          } else if (!leftCollision && rightCollision) {
            _timer.cancel();
            _gameOverTwoPlayer(context, 'left');
            return;
          } else if (futureX1 == _food[0] && futureY1 == _food[1]) {
            _queue1.addFirst([futureX1, futureY1]);
            _data[futureX1][futureY1] = _leftPlayerColor;
            _data[last1[0]][last1[1]] = _leftPlayerColor;
            _createFood();
            _queue2.addFirst([futureX2, futureY2]);
            _data[futureX2][futureY2] = _rightPlayerColor;
            _queue2.removeLast();
          } else if (futureX2 == _food[0] && futureY2 == _food[1]) {
            _queue2.addFirst([futureX2, futureY2]);
            _data[futureX2][futureY2] = _rightPlayerColor;
            _data[last2[0]][last2[1]] = _rightPlayerColor;
            _createFood();
            _queue1.addFirst([futureX1, futureY1]);
            _data[futureX1][futureY1] = _leftPlayerColor;
            _queue1.removeLast();
          } else {
            _queue1.addFirst([futureX1, futureY1]);
            _data[futureX1][futureY1] = _leftPlayerColor;
            _queue1.removeLast();
            _queue2.addFirst([futureX2, futureY2]);
            _data[futureX2][futureY2] = _rightPlayerColor;
            _queue2.removeLast();
          }
          break;
        default:
      }

      if (_step < 2) {
        _data[_food[0]][_food[1]] = _brickBkColor;
      } else {
        _data[_food[0]][_food[1]] = _foodColor;
      }
      notifyListeners();
    });
  }

  void _buttonFeedback() {
    if (_vibration == false) {
      return;
    }
    if (Vibration.hasVibrator() != null) {
      if (Vibration.hasAmplitudeControl() != null) {
        Vibration.vibrate(duration: 100, amplitude: 80);
      } else {
        Vibration.vibrate(duration: 100);
      }
    }
  }

  void upButton(String player) {
    switch (_playerNum) {
      case 1:
        if (_direction1 == _moveMap['LEFT'] ||
            _direction1 == _moveMap['RIGHT']) {
          _direction1 = _moveMap['UP']!;
          _buttonFeedback();
        }
        break;
      case 2:
        if (player == 'left') {
          if (_direction1 == _moveMap['LEFT'] ||
              _direction1 == _moveMap['RIGHT']) {
            _direction1 = _moveMap['UP']!;
          }
        } else {
          if (_direction2 == _moveMap['LEFT'] ||
              _direction2 == _moveMap['RIGHT']) {
            _direction2 = _moveMap['UP']!;
          }
        }
        break;
      default:
    }
  }

  void downButton(String player) {
    switch (_playerNum) {
      case 1:
        if (_direction1 == _moveMap['LEFT'] ||
            _direction1 == _moveMap['RIGHT']) {
          _direction1 = _moveMap['DOWN']!;
          _buttonFeedback();
        }
        break;
      case 2:
        if (player == 'left') {
          if (_direction1 == _moveMap['LEFT'] ||
              _direction1 == _moveMap['RIGHT']) {
            _direction1 = _moveMap['DOWN']!;
          }
        } else {
          if (_direction2 == _moveMap['LEFT'] ||
              _direction2 == _moveMap['RIGHT']) {
            _direction2 = _moveMap['DOWN']!;
          }
        }
        break;
      default:
    }
  }

  void leftButton(String player) {
    switch (_playerNum) {
      case 1:
        if (_direction1 == _moveMap['UP'] || _direction1 == _moveMap['DOWN']) {
          _direction1 = _moveMap['LEFT']!;
          _buttonFeedback();
        }
        break;
      case 2:
        if (player == 'left') {
          if (_direction1 == _moveMap['UP'] ||
              _direction1 == _moveMap['DOWN']) {
            _direction1 = _moveMap['LEFT']!;
          }
        } else {
          if (_direction2 == _moveMap['UP'] ||
              _direction2 == _moveMap['DOWN']) {
            _direction2 = _moveMap['LEFT']!;
          }
        }
        break;
      default:
    }
  }

  void rightButton(String player) {
    switch (_playerNum) {
      case 1:
        if (_direction1 == _moveMap['UP'] || _direction1 == _moveMap['DOWN']) {
          _direction1 = _moveMap['RIGHT']!;
          _buttonFeedback();
        }
        break;
      case 2:
        if (player == 'left') {
          if (_direction1 == _moveMap['UP'] ||
              _direction1 == _moveMap['DOWN']) {
            _direction1 = _moveMap['RIGHT']!;
          }
        } else {
          if (_direction2 == _moveMap['UP'] ||
              _direction2 == _moveMap['DOWN']) {
            _direction2 = _moveMap['RIGHT']!;
          }
        }
        break;
      default:
    }
  }

  void clickButton(IconData icon, String player) {
    if (icon == Icons.arrow_drop_up) {
      upButton(player);
    } else if (icon == Icons.arrow_drop_down) {
      downButton(player);
    } else if (icon == Icons.arrow_left) {
      leftButton(player);
    } else {
      rightButton(player);
    }
  }

  SimpleDialog configDialog(BuildContext context, String title, Map options) {
    return SimpleDialog(
      title: Text(title),
      children: options.keys.map((key) {
        return SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, key);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(key),
          ),
        );
      }).toList(),
    );
  }

  AlertDialog colorDialog(BuildContext context, int currentColor) {
    int tmpColor = currentColor;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0.0),
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: Color(currentColor),
          onColorChanged: (Color color) {
            tmpColor = color.value;
          },
          colorPickerWidth: 300.0,
          pickerAreaHeightPercent: 0.7,
          enableAlpha: true,
          displayThumbColor: true,
          paletteType: PaletteType.hsv,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel❌'),
          onPressed: () {
            Navigator.of(context).pop(-1);
          },
        ),
        TextButton(
          child: const Text('Confirm✔️'),
          onPressed: () {
            Navigator.of(context).pop(tmpColor);
          },
        ),
      ],
    );
  }

  void optionsAppBkColor(BuildContext context) async {
    var color = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return colorDialog(context, _appBkColor);
        });
    if (color != -1 && _appBkColor != color) {
      _appBkColor = color;
      notifyListeners();
    }
    if (_initFlag) {
      _initGame();
    } else {
      if (context.mounted) {
        _updateState(context);
      }
    }
  }

  void optionsLeftColor(BuildContext context) async {
    var color = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return colorDialog(context, _leftPlayerColor);
        });
    if (color != -1) {
      _leftPlayerColor = color;
      notifyListeners();
    }
    if (_initFlag) {
      _initGame();
    } else {
      if (context.mounted) {
        _updateState(context);
      }
    }
  }

  void optionsRightColor(BuildContext context) async {
    var color = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return colorDialog(context, _rightPlayerColor);
        });
    if (color != -1) {
      _rightPlayerColor = color;
      notifyListeners();
    }
    if (_initFlag) {
      _initGame();
    } else {
      if (context.mounted) {
        _updateState(context);
      }
    }
  }

  void optionsOnePlayerColor(BuildContext context) async {
    var color = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return colorDialog(context, _brickOnePlayerColor);
        });
    if (color != -1) {
      _brickOnePlayerColor = color;
      notifyListeners();
    }
    if (_initFlag) {
      _initGame();
    } else {
      _updateState(context);
    }
  }

  void optionsScoreBoardColor(BuildContext context) async {
    var color = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return colorDialog(context, _scoreBoardColor);
        });
    if (color != -1) {
      _scoreBoardColor = color;
      notifyListeners();
    }
    if (_initFlag) {
      _initGame();
    } else {
      _updateState(context);
    }
  }

  void optionsFoodColor(BuildContext context) async {
    var color = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return colorDialog(context, _foodColor);
        });
    if (color != -1) {
      _foodColor = color;
      notifyListeners();
    }
    if (_initFlag) {
      _initGame();
    } else {
      _updateState(context);
    }
  }

  void setConfig(BuildContext context) async {
    _timer.cancel();
    var gameMode = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, _modeTitle, _modeOptions);
        });
    var mapSize = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, _sizeTitle, _sizeOptions);
        });
    debugPrint("game map size：$_mapSize");
    var difficulty = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, _speedTitle, _speedOptions);
        });
    debugPrint("game speed：$_speed");
    var confirmTitle = '''Play the game under the following options?

    Game Mode: $gameMode
    Map Size: $mapSize
    Difficulty: $difficulty
    ''';
    var confirmOptions = {
      'Cancel': false,
      'START!🎬': true,
    };
    var startFlag = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return configDialog(context, confirmTitle, confirmOptions);
        });
    if (confirmOptions[startFlag]!) {
      _playerNum = _modeOptions[gameMode]!;
      _mapSize = _sizeOptions[mapSize]!;
      _speed = _speedOptions[difficulty]!;
      if (context.mounted) {
        _startGame(context);
      }
    } else {
      _initGame();
    }
  }

  void menuOpen() {
    _timer.cancel();
    _menuFlag = true;
  }

  void menuClose() {
    if (_menuFlag) {
      _initGame();
    }
  }

  void pauseGame() {
    _timer.cancel();
    _playFlag = true;
  }

  void playGame(BuildContext context) {
    if (_playFlag) {
      _updateState(context);
    }
  }

  void menuQuickRestart(BuildContext context) {
    _playFlag = false;
    _startGame(context);
  }

  void menuRestart(BuildContext context) {
    _playFlag = false;
    setConfig(context);
  }

  void menuExit(BuildContext context) {
    _playFlag = false;
    saveColorPlan(context);
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void _generateLaunchIcon() {
    var size = _initSize;
    _data = List.generate(size, (_) => List.generate(size, (_) => 0));
    _zeroData(size);
    var snakePoint = [[0,0],[0,1],[0,2],[0,3],[0,4],[0,8],[0,9],[0,10],[0,11],[0,12],
      [0,16],[1,0],[1,4],[1,8],[1,12],[1,16],[2,0],[2,4],[2,8],[2,12],[2,16],
      [3,0],[3,4],[3,8],[3,12],[3,16],[4,0],[4,4],[4,5],[4,6],[4,7],[4,8],
      [4,12],[4,13],[4,14],[4,15],[4,16],[5,0],[6,0],[7,0],[7,1],[7,2],[7,3],[7,4]];
    List<List<int>> reverse = [];
    for (var i in snakePoint){
      reverse.add([size-1-i[0],size-1-i[1]]);
    }
    _setChar(snakePoint, [2,2], 0xFFFFEB3B);
    _setChar(reverse, [-2,-2], 0xFF69F0AE);
    _data[size~/2][size~/2] = 0xDD000000; 
    notifyListeners();

    _initFlag = true;
  }
}
