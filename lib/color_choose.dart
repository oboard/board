import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oboard/main.dart';

import 'board.dart';

List<Color> colorList = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.teal,
  Colors.blue,
  Colors.purple,
  Colors.black
];

class CircleTrianglePage extends StatefulWidget {
  @override
  _CircleTriangleState createState() => _CircleTriangleState();
}

double radius = 0;
double screenW = 0, screenH = 0;
List<Widget> chooser = [];

class _CircleTriangleState extends State<CircleTrianglePage> {
  double _len = 0.0;
  double _x = 0.0;
  double _y = 0.0;

  @override
  Widget build(BuildContext context) {
    radius = MediaQuery.of(context).size.width / 3;
    screenW = MediaQuery.of(context).size.width;
    screenH = MediaQuery.of(context).size.height -
        MediaQueryData.fromWindow(window).viewInsets.bottom;
    return Container(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        child: CustomPaint(
            painter: CircleTrianglePainter(scrollLen: _len),
            child: Stack(
              children: chooser,
            )),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  final double radius;
  final double startAngle;
  final double sweepAngle;

  ArcClipper(this.radius, this.startAngle, this.sweepAngle);

  @override
  Path getClip(Size size) {
    //x坐标为0.0 y坐标为手机高度一半
    //到x坐标为手机宽度 到 手机宽度的一半减去100 达到斜线的结果
    //到x坐标为手机宽度 到 y坐标为手机宽度
    //完成
    var path = Path()
//      ..lineTo(cos(startAngle) * radius, sin(startAngle) * radius)
      ..addArc(Rect.fromCircle(center: Offset(radius, radius), radius: radius),
          startAngle, sweepAngle)
      ..lineTo(size.width / 2, size.height / 2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

const List<Point> POINT = [Point(100, 100)];

class CircleTrianglePainter extends CustomPainter {
  CircleTrianglePainter({this.scrollLen});

  final double scrollLen;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width > 1.0 && size.height > 1.0) {
//      _sizeUtil.logicSize = size;
    }

    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black
      ..strokeWidth = 2.0;

    paint.color = Colors.grey[900];

//    canvas.drawCircle(

//        Offset(_sizeUtil.getAxisX(250), _sizeUtil.getAxisY(250.0)),

//        _sizeUtil.getAxisBoth(200.0),

//        paint);

    paint.strokeWidth = 20;

    paint.style = PaintingStyle.stroke;
    paint.style = PaintingStyle.fill;

//    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),

//        1.4 * scrollLen / radius, pi / 2, true, paint);

    _drawTriCircle(
      canvas,
      paint,
      sources: [1, 1, 1, 1, 1, 1, 1, 1],
      colors: colorList,
      radius: radius,
      startRadian: scrollLen / radius,
    );

    canvas.save();

    canvas.restore();
  }

  void _drawTriCircle(Canvas canvas, Paint paint,
      {double radius,
      List<double> sources,
      List<Color> colors,
      double startRadian}) {
    assert(sources != null && sources.length > 0);

    assert(colors != null && colors.length > 0);

    var total = 0.0;

    for (var d in sources) {
      total += d;
    }

    List<double> radians = [];

    for (var data in sources) {
      radians.add(data * 2 * pi / total);
    }

    //!!!
    chooser.clear();
    for (int i = 0; i < radians.length; i++) {
      paint.color = colors[i % colors.length];

//      canvas.drawArc(
//          Rect.fromCircle(center: Offset(radius, radius), radius: radius),
//          startRadian,
//          radians[i],
//          true,
//          paint);
      //!!!
      chooser.add(
        ClipPath(
          clipper: ArcClipper(
            radius,
            startRadian,
            radians[i],
          ),
          child: Container(
            color: colors[i % colors.length],
            child: GestureDetector(
              onTapDown: (detail) {
                paintColor = colors[i % colors.length];
                eventBus.fire('');
                print(paintColor);
              },
            ),
          ),
        ),
      );

      startRadian += radians[i];
    }
  }

  @override
  bool shouldRepaint(CircleTrianglePainter oldDelegate) =>
      oldDelegate.scrollLen != scrollLen;
}
