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
    return Container(
      padding: EdgeInsets.only(top: 20),
      color: Colors.grey[300],
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            child: !isFilling
                ? Text(
                    "  Hi, You can draw anything in the box To fill with color just touch anywhere in the box. It will fill the tightly closed region with black     NOTE: This program is too slow, Make a small area and touch inside it to get the result immediately ",
                    textScaleFactor: 1.2,
                    textAlign: TextAlign.center,
                  )
                : Column(
                    children: <Widget>[
                      Text(
                        " Touched Point - $touchPoint . Bucket filling... Please Wait ",
                        textScaleFactor: 1.3,
                        textAlign: TextAlign.center,
                      ),
                      CircularProgressIndicator()
                    ],
                  ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.blueGrey[300],
                  width: 2.0,
                ),
              ),
              width: 150,
              height: 150,
              child: RepaintBoundary(
                key: key,
                child: GestureDetector(
                  onTapUp: !isFilling
                      ? (tapDetail) => _ondtap(tapDetail, context, key)
                      : null,
                  onPanUpdate: (details) {
                    setState(() {
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
                    painter: DrawingPainter(
                      pointsList: points,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                    height: 40,
                    child: Center(
                        child: Text(
                      "Clear the box - ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.3,
                    )))),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                width: 50,
             //   color: Colors.white,
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 40,
                  ),
                  tooltip: 'Clean the box',
                  onPressed: () {
                    setState(() {
                      points.clear();
                    });
                  },
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _ondtap(TapUpDetails tapUpDetail, context, key) async {
    print("bUCKET FILLER START ");
    setState(() {
      _dialogBox();

      isFilling = true;
      touchPoint = tapUpDetail.localPosition;
    });

    List<Offset> offset = [];
    points.forEach((f) {
      if (f != null) {
        offset.add(f.points);
      }
    });
    var stopwatch = new Stopwatch()..start();
    BucketFill().capturePng(key, touchPoint, offset).then((data) {
      stopwatch.stop();

      print('result came  ${data.length}');
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
        isFilling = false;
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
