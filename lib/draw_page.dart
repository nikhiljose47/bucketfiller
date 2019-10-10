import 'package:bucketfiller/bucket_fill.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class Drawing extends StatefulWidget {
  Drawing({Key key}) : super(key: key);

  DrawingState createState() => DrawingState();
}

class DrawingState extends State<Drawing> {
  double wop = 9.98;
  GlobalKey key = new GlobalKey();
  Stopwatch stopwatch;
  List<Offset> store = [];
  List<DrawingPoints> points = List();

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = StrokeCap.round;
  Offset touchPoint;
  bool isFilling = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: double.infinity,
          color: Colors.grey[300],
          child: !isFilling
              ? Text(
                  "  Hi, After drawing ,just touch anywhere to fill with color",
                  textScaleFactor: 1.2,
                  maxLines: 2,
                )
              : Column(
                  children: <Widget>[
                    Text(
                      " Touched Point - $touchPoint",
                      textScaleFactor: 1.2,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
        ),
        Expanded(
          child: RepaintBoundary(
            key: key,
            child: GestureDetector(
              onTapUp: (tapDetail) => _ondtap(tapDetail, context, key),
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject();
                  points.add(DrawingPoints(
                      points: details.localPosition,
                      paint: Paint()
                        ..strokeCap = strokeCap
                        ..isAntiAlias = true
                        ..color = selectedColor.withOpacity(opacity)
                        ..strokeWidth = strokeWidth));
                });
              },
              onPanStart: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject();
                  points.add(DrawingPoints(
                      points: details.localPosition,
                      paint: Paint()
                        ..strokeCap = strokeCap
                        ..isAntiAlias = true
                        ..color = selectedColor.withOpacity(opacity)
                        ..strokeWidth = strokeWidth));
                });
              },
              onPanEnd: (details) {
                 points.add(null);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawingPainter(
                  pointsList: points,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  void _ondtap(TapUpDetails tapUpDetail, context, key) async {
    print("bUCKET FILLER START ");
    _dialogBox();
    setState(() {
      isFilling = true;
      touchPoint = tapUpDetail.localPosition;
    });

    List<Offset> offset = [];
    points.forEach((f) => offset.add(f.points));
    var stopwatch = new Stopwatch()..start();
    BucketFill().capturePng(key, touchPoint, offset).then((data) {
      stopwatch.stop();
      print('stopwatch  ${stopwatch.elapsedMilliseconds}');
      print('data  $data');
      print('kolp  ${data.length}');
      setState(() {
        for (var i = 1; i < data.length; i++) {
          points.add(DrawingPoints(
              points: data[i],
              paint: Paint()
                ..strokeCap = strokeCap
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        }
      });
     Navigator.of(context).pop();
    });
  }

  Future<void> _dialogBox() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Please wait '),
        content: CircularProgressIndicator(),   
      );
    },
  );
}
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
