import 'dart:ui';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import 'main.dart';

EventBus boardEvent = EventBus();
Color paintColor = Colors.black;

class BoardPainter extends CustomPainter {
  /// 帧集合
  final List<Frame> frames;

  BoardPainter({this.frames});

  /// 初始化画笔
  var lineP = Paint()
    ..strokeWidth = 5.0
    ..isAntiAlias = false
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (frames.length == 0) return;
    canvas.translate(sy * 20, sx * 20);
    for (int i = 0; i < frames.length; i++) {
      lineP..color = frames[i].color;

      /// 当前frame 点集合
      List<Offset> currentPoints = frames[i].points;

      if (currentPoints == null || currentPoints.length == 0) return;
      canvas.drawPoints(PointMode.polygon, currentPoints, lineP);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Frame {
  /// 绘制的点集合
  List<Offset> points;
  Color color;

  Frame(this.points, this.color);
}

class Board extends StatefulWidget {
  BoardState createState() => new BoardState();
}

class BoardState extends State<Board> {
//  List<Offset> _points = <Offset>[], _pointsLast = <Offset>[];
//  List<CustomPaint> painters;

  List<Frame> frames = [Frame([], Colors.red)];

  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BoardPainter(frames: frames),
      child: GestureDetector(
        onPanStart: (details) {
          /// 开始绘制 可以初始化一些配置
          frames.last.color = paintColor;
        },
        onPanUpdate: (details) {
          /// 拖动更新
          RenderBox renderBox = context.findRenderObject();
          Offset _currentPoint =
              renderBox.globalToLocal(details.globalPosition);
          Offset currentPoint =
              Offset(_currentPoint.dx - sy * 20, _currentPoint.dy - sx * 20);
          setState(() {
            frames.last.points.add(currentPoint);
          });
        },
        onPanEnd: (details) {
          Color _randomColor = Colors.black;
          frames.add(Frame([], _randomColor));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    boardEvent.on<String>().listen((event) {
      switch (event) {
        case 'clear':
          frames.clear();
          frames = [Frame([], Colors.red)];
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    boardEvent.destroy();
  }
}
