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

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<Offset> points = List();
  bool showBottomList = false;
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: key,
      child: GestureDetector(
        onDoubleTap:()=> _ondtap(context, key, store),
        
          onScaleUpdate: (ScaleUpdateDetails update) =>
              _onScaleUpdate(context, update),
          onScaleEnd: (ScaleEndDetails end) => _onScaleEnd(context, end),
       
        
       
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
            pointsList: points,
          ),
        ),
      ),
    );
  }

//pixel Offset(451.0, 390.0)
//emulator Offset(193.8, 137.5)
  void _ondtap(BuildContext context, key, store) {
    PainterController painterController =
        ActivityModel.of(context).painterController;
    var stopwatch = new Stopwatch()..start();
    BucketFill().capturePng(key, Offset(193.8, 137.5), store).then((data) {
      stopwatch.stop();
      data.add(null);
      print('stopwatch  ${stopwatch.elapsedMilliseconds}');
      print('data  $data');
      print('kolp  ${data.length}');
      painterController.add(data[0]);

      for (var i = 1; i < data.length; i++) {
        painterController.updateCurrent(data[i]);
      }
    });
  }
  void _onScaleStart(BuildContext context, ScaleStartDetails start) {   
    PainterController painterController =
        ActivityModel.of(context).painterController;
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(start.focalPoint);
    painterController._pathHistory.add(pos);
    painterController._notifyListeners();
  }

  void _onScaleUpdate(BuildContext context, ScaleUpdateDetails update) {
    if (update.scale == 1.0) {
      Offset pos = (context.findRenderObject() as RenderBox)
          .globalToLocal(update.focalPoint);
     //   print('store  $store');
        this.store = List.from(this.store)..add(pos);
      } else {
        
        this.store = List.from(this.store)..add(pos);
        print('store  $store');

      }
    }
  }

  void _onScaleEnd(BuildContext context, ScaleEndDetails end) {
    ActivityModel model = ActivityModel.of(context);
    PathHistory pathHistory = ActivityModel.of(context).pathHistory;
    PainterController painterController = model.painterController;
    painterController.endCurrent();
    model.addDrawing(pathHistory.paths.last); //TODO do this in pathhistory
    painterController.notifyListeners();
  }
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

