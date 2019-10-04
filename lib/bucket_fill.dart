import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/rendering.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

class BucketFill {
  List<bool> pc = [];
  double lfill;
  double rfill;
  Queue<FloodFillRange> ranges;
  FloodFillRange range;
  List<Offset> _points = <Offset>[];
  List<Offset> _path = <Offset>[];
  List<FloodFillRange> flist = [];
  ByteData rgbaImageData1;
  Uint8List byte;
  Uint32List words;
  static int width;
  Color oldColor;
  int imageWidth;
  int imageHeight;
  Stopwatch stopwatch;
  int i = 0;
  var qw=0;
  double x1;
  double y1;
  var runcount = 0;
  final Color fillColor = Colors.green;

  Future<List> capturePng(
      GlobalKey key, Offset offset, List<Offset> offlist) async {
    print('came  $key  $offset $offlist');
    _points = [];
    offlist.forEach((e) => _path
        .add(Offset((e.dx / 10).floorToDouble(), (e.dy / 10).floorToDouble())));
    print('path    $_path');
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final rgbaImageData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    // rgbaImageData1 = rgbaImageData;
    imageHeight = image.height;
    imageWidth = image.width;
    // byte = Uint8List.view(rgbaImageData.buffer, rgbaImageData.offsetInBytes,
    //     rgbaImageData.lengthInBytes);
    words = Uint32List.view(rgbaImageData.buffer, rgbaImageData.offsetInBytes,
        rgbaImageData.lengthInBytes ~/ Uint32List.bytesPerElement);
    oldColor = _getColor(words, offset.dx, offset.dy);
    int op = 100000; //pixel 1.2sec
    var stopwatch = new Stopwatch()..start();
    List _points1 = [];
    while (op > 0) {
      op--;
      _findboundary(50.0, 20.0);
        //    bool t= _path.contains(Offset(offset.dx+1, offset.dy-1));  //1.2sec
// bool o=  _getColor(words, 20.0, 30.0) == oldColor;
    }
    print('op $_points1');
    stopwatch.stop();
    //stopwatch.elapsedMilliseconds;
    print(
        'before call $imageHeight $imageWidth ${stopwatch.elapsedMilliseconds}');
    int rank = 1;
    // return _floodfill(oldColor, offset.dx, offset.dy);
    // print('before call');
     return _floodFill(
         rgbaImageData, offset.dx, offset.dy, oldColor, Colors.black);
 //   Floodfill(offset.dx, offset.dy, oldColor);
    // floodFillScanline(offset.dx, offset.dy, Colors.black, oldColor);
    return _points;
    // return _MyFill(
    //     offset.dx.toInt(), offset.dy.toInt(), imageWidth, imageHeight);
    //  return ScanlineFill(rgbaImageData, offset.dx.toInt(), offset.dy.toInt(),imageHeight,imageWidth, oldColor);
  }

  void _addpoints(double x, double y) {
    if (_points.last != Offset(x, y)) _points.add(Offset(x, y));
  }

  List<Offset> _floodFill(ByteData rgbaImageData, double x, double y,
      Color oldColor, Color newColor) {
    if (_getColor(words, x, y) == newColor) return null;
    if (oldColor == newColor) return null;
    Queue<Offset> queue = new Queue();
   List<Offset> lq=[];
    lq.add(Offset(x, y));
  int mac=0;
    while (lq.isNotEmpty) {
      mac++;
      Offset w = lq.first;
      Offset e = lq.first;
      // print('queue is $queue');
      //  print('object ${queue.first} $w  ${i++}');
      while (_shouldFillColor(w.dx - 1, w.dy)) {      
        w = w.translate(-1.0, 0.0);
         _points.add(Offset(w.dx, w.dy));
      }

      while (_shouldFillColor(e.dx + 1, w.dy)) {
        e = e.translate(1.0, 0.0);
        _points.add(Offset(e.dx, w.dy));
      }
      double tem=w.dx+4.0;
   //   var skip = 0;
      while (w.dx <= e.dx) {
        if (_shouldFillColor(w.dx, w.dy - 1)) {
        lq.add(Offset(w.dx, w.dy - 1));
        }

        if (_shouldFillColor(w.dx, w.dy + 1)) {
        lq.add(Offset(w.dx, w.dy + 1));
        }
        w = w.translate(1.0, 0.0);
      }
      lq.removeAt(0);
    }
    return _points;
  }

  //1856
  List<Offset> _floodfill(Color oldColor, double x, double y) {
    runcount++;
    //   print('inside fn $x $y');
    if ((x >= 0 &&
            x < imageWidth &&
            y >= 0 &&
            y < imageHeight &&
            !_points.contains(Offset(x, y)))
        ? _getColor(words, x, y) == oldColor
        : false) {
      _points.add(Offset(x, y));

//       while(!_findboundary(x, y) && x >= 0 &&
//             x < imageWidth &&
//             y >= 0 &&
//             y < imageHeight){
//         print('going $x  $y   $rank' );

//               switch (rank){
//           case 1:{ if(_points.last!=Offset(x,y))
// _points.add(Offset(x, y));x=x>=0||x<imageWidth?x+2:0;break;}

//           case 2:{ if(_points.last!=Offset(x,y))
// _points.add(Offset(x, y));x=x>=0||x<imageWidth?x-2:0;break;}

//      case 3:{ if(_points.last!=Offset(x,y))
// _points.add(Offset(x, y));y=y>=0||y<imageWidth?y+2:0;break;}

//       case 4:{ if(_points.last!=Offset(x,y))
// _points.add(Offset(x, y));y=y>=0||y<imageWidth?y-2:0;break;}
//       }}
      //   print('object   $_points');
      _floodfill(oldColor, x + 2, y);
      _floodfill(oldColor, x - 2, y);
      _floodfill(oldColor, x, y + 2);
      _floodfill(oldColor, x, y - 2);

      // _floodfill(oldColor, x + 4, y + 4);
      // _floodfill(oldColor, x + 4, y - 4);
      // _floodfill(oldColor, x - 4, y + 4);
      // _floodfill(oldColor, x - 4, y + 4);
    }
    print('run count =  $runcount');
    return _points;
  }

  bool _shouldFillColor(double x, double y) {
    qw++;
    return (x >= 0 &&
            x < imageWidth &&
            y >= 0 &&
            y < imageHeight &&
            !_points.contains(Offset(x, y)))
        ? _getColor(words, x, y) == oldColor
        : false;
    //  _pathcheck(x, y)
    // _getColor(words, x, y)==oldColor
    // );
  }

  bool _shouldFillColor1(double x, double y) {
    int op = (x >= 0 &&
            x < imageWidth &&
            y >= 0 &&
            y < imageHeight &&
            !_points.contains(Offset(x, y)))
        ? !_findboundary(x, y) ? 3 : 2
        : 1;
    switch (op) {
      case 1:
        return false;
      case 2:
        return _getColor(words, x, y) == oldColor;
      case 3:
        return true;
    }

    //  _pathcheck(x, y)
    // _getColor(words, x, y)==oldColor
    // );
  }

  bool _findboundary(double x2, double y2) {
    x1 = (x2 / 10).floorToDouble();
    y1 = (y2 / 10).floorToDouble();
    if (_path.contains(Offset(x1, y1)) ||
        _path.contains(Offset(x1 - 1, y1)) ||
        _path.contains(Offset(x1 + 1, y1)) ||
        _path.contains(Offset(x1, y1 + 1)) ||
        _path.contains(Offset(x1, y1 - 1))) {
      return true;
    }
    return false;
  }

  List<Offset> _floodFill5(
      ByteData rgb, double x, double y, Color col, Color col1) {
    Queue<Offset> queue = new Queue();
    Offset temp;
    queue.add(Offset(x, y));
    _points = List.from(_points)..add(queue.first);
    while (queue.isNotEmpty) {
      temp = queue.first;
      //  print('before  $queue');
      queue.removeFirst();
      if (_shouldFillColor1(temp.dx + 2, temp.dy)) {
        queue.add(Offset(temp.dx + 2, temp.dy));
        _points.add(Offset(temp.dx + 2, temp.dy));
      }
      if (_shouldFillColor1(temp.dx - 2, temp.dy)) {
        queue.add(Offset(temp.dx - 2, temp.dy));
        _points.add(Offset(temp.dx - 2, temp.dy));
      }
      if (_shouldFillColor1(temp.dx, temp.dy + 2)) {
        queue.add(Offset(temp.dx, temp.dy + 2));
        _points.add(Offset(temp.dx, temp.dy + 2));
      }
      if (_shouldFillColor1(temp.dx, temp.dy - 2)) {
        queue.add(Offset(temp.dx, temp.dy - 2));
        _points.add(Offset(temp.dx, temp.dy - 2));
      }
    }
    _points.add(null);
    return _points;
  }

// 54 sec pixel face
//29 sec
  List<Offset> _floodFill2(
      ByteData rgb, double x, double y, Color col, Color col1) {
    Queue<Offset> queue = new Queue();
    Offset temp;
    queue.add(Offset(x, y));
    _points = List.from(_points)..add(queue.first);
    while (queue.isNotEmpty && runcount < 14100) {
      runcount++;
      temp = queue.first;
      //  print('before  $queue');
      queue.removeFirst();
      if (_shouldFillColor1(temp.dx + 2, temp.dy)) {
        queue.add(Offset(temp.dx + 2, temp.dy));
        _points.add(Offset(temp.dx + 2, temp.dy));
      }
      //  else if (_getColor(words, temp.dx + 2, temp.dy) == oldColor) {
      //   queue.add(Offset(temp.dx + 2, temp.dy));
      //   _points.add(Offset(temp.dx + 2, temp.dy));
      // }

      if (_shouldFillColor1(temp.dx - 2, temp.dy)) {
        queue.add(Offset(temp.dx - 2, temp.dy));
        _points.add(Offset(temp.dx - 2, temp.dy));
      }
      // else if (_getColor(words, temp.dx - 2, temp.dy) == oldColor) {
      //   queue.add(Offset(temp.dx - 2, temp.dy));
      //   _points.add(Offset(temp.dx - 2, temp.dy));
      // }

      // if (_shouldFillColor1(temp.dx - 2, temp.dy)) {
      //   queue.add(Offset(temp.dx - 2, temp.dy));
      //   _points.add(Offset(temp.dx - 2, temp.dy));
      // }
      if (_shouldFillColor1(temp.dx, temp.dy + 2)) {
        queue.add(Offset(temp.dx, temp.dy + 2));
        _points.add(Offset(temp.dx, temp.dy + 2));
      }
      //  else if (_getColor(words, temp.dx, temp.dy + 2) == oldColor) {
      //   queue.add(Offset(temp.dx, temp.dy + 2));
      //   _points.add(Offset(temp.dx, temp.dy + 2));
      // }

      // if (_shouldFillColor1(temp.dx, temp.dy + 2)) {
      //   queue.add(Offset(temp.dx, temp.dy  d+ 2));
      //   _points.add(Offset(temp.dx, temp.dy + 2));
      // }
      //
      if (_shouldFillColor1(temp.dx, temp.dy - 2)) {
        queue.add(Offset(temp.dx, temp.dy - 2));
        _points.add(Offset(temp.dx, temp.dy - 2));
      }
      //  else if (_getColor(words, temp.dx, temp.dy - 2) == oldColor) {
      //   queue.add(Offset(temp.dx, temp.dy - 2));
      //   _points.add(Offset(temp.dx, temp.dy - 2));
      // }

      // if (_shouldFillColor1(temp.dx, temp.dy - 2)) {
      //   queue.add(Offset(temp.dx, temp.dy - 2));
      //   _points.add(Offset(temp.dx, temp.dy - 2));
      // }
    }
    _points.add(null);
    print('run count =  $runcount');
    return _points;
  }

  Color _getColor(Uint32List words, double x1, double y1) {
    int x = x1.toInt();
    int y = y1.toInt();
    var offset = x + y * imageWidth;
    return Color(words[offset]);
  }

  linearFill(x, y) {
    print('inside fn $x $y');
    double y1 = y;
    rfill = x;
    lfill = x;

    while (true) {
      print('inside fn while $x $y');
      _points.add(Offset(x1, y1));
      lfill--;
      if ((lfill <= 0 || _points.contains(Offset(lfill, y1)))
          ? true
          : _getColor(words, lfill, y1) != oldColor) break;
    }
    lfill++;
 print('lfill   $lfill ');
    while (true) {
      print('inside fn while 2 $x $y');
         if ((lfill >= imageWidth || _points.contains(Offset(rfill, y1)))
          ? true
          : _getColor(words, rfill, y1) != oldColor) break;
      _points.add(Offset(rfill, y1));
      rfill++;
   
    }
    
    print('inside fn while outside $x $y');
    rfill--;
    FloodFillRange r = new FloodFillRange(lfill, rfill, y);
    print('inside fn while outside  ii $x $y');
    flist.add(r);
    print('inside fn while outside  ii21 $x $y');
  }

  Floodfill(double x, double y, Color oldColor) {
    double x1 = x;
    double y1 = y;

    linearFill(x1, y1);
    print('came ${flist.length}');
    while (flist.length > 0) {
    print('object  $x');
   
      range = flist.removeLast();
         print('inside while ${range.lfill} ${range.rfill}');
      double upY = range.y - 1;
      double downY = range.y + 1;
      //  Offset tempIdx;
      for (double i = range.lfill; i <= range.rfill; i++) {
        print('inside for loopp $i');
        // tempIdx = Offset(i.toDouble(), upY.toDouble());
        if (range.y > 0 &&
                (!_points.contains(Offset((range.y - 1), range.lfill)))
            ? _getColor(words, i.toDouble(), upY.toDouble()) == oldColor
            : false) linearFill(i, upY);
        if (range.y < imageWidth &&
                (!_points.contains(Offset((range.y + 1), range.lfill)))
            ? _getColor(words, i.toDouble(), upY.toDouble()) == oldColor
            : false) linearFill(i, downY);
      }
    }
  }
}

class FloodFillRange {
   final double lfill;

   final double rfill;

   final double y;

  FloodFillRange(this.lfill, this.rfill, this.y);
  // final lfill = 0.0;
  // final EndX = rfill;
  // final Y = y;
}

//  bool _shouldFillColor3(double x, double y) {
//     return (
//             !_points.contains(Offset(x, y)))
//         ? _getColor(words, x, y) == oldColor
//         : false;
//     //  _pathcheck(x, y)
//     // _getColor(words, x, y)==oldColor
//     // );
//   }

// //stack friendly and fast floodfill algorithm, using recursive function calls
//  floodFillScanline(double x, double y, Color newColor, Color oldColor)
// {

//   if(!_points.contains(Offset(x, y)) &&
//        _getColor(words, x, y) == oldColor){
// print('came $x $y');
//   double x1;

//   //draw current scanline from start position to the right
//   x1 = x;
//   while(x1 < imageWidth &&  _shouldFillColor3(y,x1))
//   {
//    _points.add(Offset(y,x1));
//     x1++;
//   }

//   //draw current scanline from start position to the left
//   x1 = x - 1;
//   while(x1 >= 0 && _shouldFillColor3(y,x1))
//   {
//    _points.add(Offset(y,x1));
//     x1--;
//   }

//   //test for new scanlines above
//   x1 = x;
//   while(x1 < imageWidth && _shouldFillColor3(y,x1))
//   {
//     if(y > 0 && _shouldFillColor3(y-1,x1))
//     {
//       floodFillScanline( x1, y - 1, newColor, oldColor);
//     }
//     x1++;
//   }
//   x1 = x - 1;
//   while(x1 >= 0 && !_shouldFillColor3(y,x1))
//   {
//     if(y > 0 && _shouldFillColor3(y-1,x1))
//     {
//       floodFillScanline( x1, y - 1, newColor, oldColor);
//     }
//     x1--;
//   }

//   //test for new scanlines below
//   x1 = x;
//   while(x1 < imageWidth && !_shouldFillColor3(y,x1))
//   {
//     if(y < imageHeight - 1 && _shouldFillColor3(y+1,x1))
//     {
//       floodFillScanline( x1, y + 1, newColor, oldColor);
//     }
//     x1++;
//   }
//   x1 = x - 1;
//   while(x1 >= 0 && !_shouldFillColor3(y,x1))
//   {
//     if(y < imageHeight - 1 && _shouldFillColor3(y+1,x1))
//     {
//       floodFillScanline( x1, y + 1, newColor, oldColor);
//     }
//     x1--;
//   }
// }
// }

//  bool array(var x,var y){
//    return _points.contains(Offset(x, y))
//       && _getColor(words, x, y) != oldColor;
//  }

//  MyFill2(int x, int y)
// {
//   if(!array(y, x)) _MyFill( x, y, imageWidth, imageHeight);
// }

// _MyFill( int x, int y, int width, int height)
// {
//    print('came in myfill');
//   // at this point, we know array[y,x] is clear, and we want to move as far as possible to the upper-left. moving
//   // up is much more important than moving left, so we could try to make this smarter by sometimes moving to
//   // the right if doing so would allow us to move further up, but it doesn't seem worth the complexity
//   // while(true)
//   // {
//   //   int ox = x, oy = y;
//   //   while(y != 0 && !array(y-1, x)) y--;
//   //   while(x != 0 && !array(y, x-1)) x--;
//   //   if(x == ox && y == oy) break;
//   // }
//   print('stopped');
//   MyFillCore( 400, 1, width, height);
//   return _points;
// }

//  MyFillCore( int x, int y, int width, int height)
// {
//   print('came in myfillcore');
//   // at this point, we know that array[y,x] is clear, and array[y-1,x] and array[y,x-1] are set.
//   // we'll begin scanning down and to the right, attempting to fill an entire rectangular block
//   int lastRowLength = 0; // the number of cells that were clear in the last row we scanned
//   do
//   {
//     int rowLength = 0, sx = x; // keep track of how long this row is. sx is the starting x for the main scan below
//     // now we want to handle a case like |***|, where we fill 3 cells in the first row and then after we move to
//     // the second row we find the first  | **| cell is filled, ending our rectangular scan. rather than handling
//     // this via the recursion below, we'll increase the starting value of 'x' and reduce the last row length to
//     // match. then we'll continue trying to set the narrower rectangular block
//     if(lastRowLength != 0 && array(y, x)) // if this is not the first row and the leftmost cell is filled...
//     {
//       do
//       {
//          print('runnning  $x $y');
//         if(--lastRowLength == 0) return true; // shorten the row. if it's full, we're done
//       } while(array(y, ++x)); // otherwise, update the starting point of the main scan to match
//       sx = x;
//     }
//     // we also want to handle the opposite case, | **|, where we begin scanning a 2-wide rectangular block and
//     // then find on the next row that it has     |***| gotten wider on the left. again, we could handle this
//     // with recursion but we'd prefer to adjust x and lastRowLength instead
//     else
//     {
//     print('came here ');
//       for(; x != 0 && !array(y, x-1); rowLength++, lastRowLength++)
//       {
//           print('runnning  $x $y');
//         _points.add(Offset(y.toDouble(),(--x).toDouble()));
//        // to avoid scanning the cells twice, we'll fill them and update rowLength here
//         // if there's something above the new starting point, handle that recursively. this deals with cases
//         // like |* **| when we begin filling from (2,0), move down to (2,1), and then move left to (0,1).
//         // the  |****| main scan assumes the portion of the previous row from x to x+lastRowLength has already
//         // been filled. adjusting x and lastRowLength breaks that assumption in this case, so we must fix it
//         if(y != 0 && !array(y-1, x)) _MyFill( x, y-1, width, height); // use _Fill since there may be more up and left
//       }
//       print('outside for loop');
//     }

//     // now at this point we can begin to scan the current row in the rectangular block. the span of the previous
//     // row from x (inclusive) to x+lastRowLength (exclusive) has already been filled, so we don't need to
//     // check it. so scan across to the right in the current row
//     for(; sx < width && !array(y, sx); rowLength++, sx++) _points.add(Offset(y.toDouble(),sx.toDouble()));
//     // now we've scanned this row. if the block is rectangular, then the previous row has already been scanned,
//     // so we don't need to look upwards and we're going to scan the next row in the next iteration so we don't
//     // need to look downwards. however, if the block is not rectangular, we may need to look upwards or rightwards
//     // for some portion of the row. if this row was shorter than the last row, we may need to look rightwards near
//     // the end, as in the case of |*****|, where the first row is 5 cells long and the second row is 3 cells long.
//     // we must look to the right  |*** *| of the single cell at the end of the second row, i.e. at (4,1)
//     if(rowLength < lastRowLength)
//     {
//       for(int end=x+lastRowLength; ++sx < end; ) // 'end' is the end of the previous row, so scan the current row to
//       {                                          // there. any clear cells would have been connected to the previous
//         if(!array(y, sx)) MyFillCore(sx, y, width, height); // row. the cells up and left must be set so use FillCore
//       }
//     }
//     // alternately, if this row is longer than the previous row, as in the case |*** *| then we must look above
//     // the end of the row, i.e at (4,0)                                         |*****|
//     else if(rowLength > lastRowLength && y != 0) // if this row is longer and we're not already at the top...
//     {
//       for(int ux=x+lastRowLength; ++ux<sx; ) // sx is the end of the current row
//       {
//         if(!array(y-1, ux)) _MyFill( ux, y-1, width, height); // since there may be clear cells up and left, use _Fill
//       }
//     }
//     lastRowLength = rowLength; // record the new row length
//   } while(lastRowLength != 0 && ++y < height);
//    // if we get to a full row or to the bottom, we're done
// }

//     bool _shouldFillColorx(double x, double y) {
//     return (x >= 0 &&
//             x < imageWidth &&
//             !_points.contains(Offset(x, y)));
//     //  _pathcheck(x, y)
//     // _getColor(words, x, y)==oldColor
//     // );
//   }

//   ScanlineFTFill(double x, double y,int height,int weight)
// {
// //  int height = array.GetLength(0), width = array.GetLength(1);
//   // we'll maintain a stack of points representing horizontal line segments that need to be filled.
//   // for each point, we'll fill left and right until we find the boundaries
//   Queue<Offset> points = new Queue<Offset>();
//   points.add(new Offset(x, y)); // add the initial point
//   do
//   {
//     Offset pt = points.removeLast(); // pop a line segment from the stack
//     // we'll keep track of the transitions between set and clear cells both above and below the line segment that
//     // we're filling. on a transition from a filled cell to a clear cell, we'll push that point as a new segment
//     bool setAbove = true, setBelow = true; // initially consider them set so that a clear cell is immediately pushed
//     for(x=pt.dx;  x < imageWidth &&
//             !_points.contains(Offset(pt.dy, y)); x++) // scan to the right
//     {
//       _points.add(Offset(pt.dy,y));
//       if(pt.dy > 0 && _points.contains(Offset(pt.dy-1, y)) != setAbove) // if there's a transition in the cell above...
//       {
//         setAbove = !setAbove;
//         if(!setAbove) points.add(new Offset(x, pt.dy-1)); // push the new point if it transitioned to clear
//       }
//       if(pt.dy < height-1 && _points.contains(Offset(pt.dy+1, y)) != setBelow) // if there's a transition in the cell below...
//       {
//         setBelow = !setBelow;
//         if(!setBelow) points.add(new Offset(x, pt.dy+1));
//       }
//     }

//     if(pt.dx > 0) // now we'll scan to the left, if there's anything to the left
//     {
//       // this time, we want to initialize the flags based on the actual cell values so that we don't add the line
//       // segments twice. (e.g. if it's clear above, it needs to transition to set and then back to clear.)
//       setAbove = pt.dy > 0 && _points.contains(Offset(pt.dy-1, pt.dx));
//       setBelow = pt.dy < height-1 && _points.contains(Offset(pt.dy+1, pt.dx));
//       for(x=pt.dx-1; x >= 0 && !_points.contains(Offset(pt.dy, x)); x--) // scan to the left
//       {
//         _points.add(Offset(pt.dy,x));
//         if(pt.dy > 0 && _points.contains(Offset(pt.dy-1, x)) != setAbove) // if there's a transition in the cell above...
//         {
//           setAbove = !setAbove;
//           if(!setAbove) points.add(new Offset(x, pt.dy-1)); // push the new point if it transitioned to clear
//         }
//         if(pt.dy < height-1 && _points.contains(Offset(pt.dy+1, x))!= setBelow) // if there's a transition in the cell below...
//         {
//           setBelow = !setBelow;
//           if(!setBelow) points.add(new Offset(x, pt.dy+1));
//         }
//       }
//     }
//   } while(points.length != 0);
// }

//  ScanlineFill(img, int x, int y, int height, int width,Color oldcolor) {
//     test(var x, var y) {
//       return (x >= 0 &&
//               x < imageWidth &&
//               y >= 0 &&
//               y < imageHeight &&
//               !_points.contains(Offset(x, y)))
//           ? _getColor(words, x, y) == oldColor
//           : false;
//     }

//     _points.add(Offset(x.toDouble(), y.toDouble()));
//     // if(test(array[y, x])) return;
//     // array[y, x] = true;

//     //int height = array.GetLength(0), width = array.GetLength(1);
//     Queue<Segment> stack = new Queue<Segment>();
//     stack.add(new Segment(x, x + 1, y, 0, true, true));
//     do {

//       Segment r = stack.removeFirst();
//       int startX = r.StartX, endX = r.EndX;
//       print('running  $startX  $endX');
//       if (r.ScanLeft) // if we should extend the segment towards the left...
//       {
//         while (startX > 0 && !test(r.Y, startX - 1))
//           _points.add(Offset(
//               x.toDouble(), y.toDouble())); // do so, and fill cells as we go
//       }
//       if (r.ScanRight) {
//         while (endX < width && !test(r.Y, endX))
//           _points.add(Offset(x.toDouble(), y.toDouble()));

//       }
//       // at this point, the segment from startX (inclusive) to endX (exclusive) is filled. compute the region to ignore
//       r.StartX--; // since the segment is bounded on either side by filled cells or array edges, we can extend the size of
//       r.EndX++; // the region that we're going to ignore in the adjacent lines by one
//       // scan above and below the segment and add any new segments we find
//       if (r.Y > 0)
//         AddLine(stack, startX, endX, r.Y - 1, r.StartX, r.EndX, -1, r.Dir <= 0,
//             _points, test);
//       if (r.Y < height - 1)
//         AddLine(stack, startX, endX, r.Y + 1, r.StartX, r.EndX, 1, r.Dir >= 0,
//             _points, test);
//     } while (stack.length != 0);

//     return _points;
//   }

//   static void AddLine(
//       Queue<Segment> stack,
//       int startX,
//       int endX,
//       int y,
//       int ignoreStart,
//       int ignoreEnd,
//       var dir,
//       bool isNextInDir,
//       List<Offset> _points,
//       Function test) {
//     int regionStart = -1, x;
//     for (x = startX; x < endX; x++) // scan the width of the parent segment
//     {
//       if ((isNextInDir || x < ignoreStart || x >= ignoreEnd) &&
//           !test(y, x)) // if we're outside the region we
//       {
//         // should ignore and the cell is clear
//         _points.add(Offset(x.toDouble(), y.toDouble())); // fill the cell
//         if (regionStart < 0)
//           regionStart = x; // and start a new segment if we haven't already
//       } else if (regionStart >=
//           0) // otherwise, if we shouldn't fill this cell and we have a current segment...
//       {
//         stack.add(new Segment(regionStart, x, y, dir, regionStart == startX,
//             false)); // push the segment
//         regionStart = -1; // and end it
//       }
//       if (!isNextInDir && x < ignoreEnd && x >= ignoreStart)
//         x = ignoreEnd - 1; // skip over the ignored region
//     }
//     if (regionStart >= 0)
//       stack.add(
//           new Segment(regionStart, x, y, dir, regionStart == startX, true));
//   }
// }

// class Segment {
//     int StartX, EndX, Y;
//   var Dir; // -1:above the previous segment, 1:below the previous segment, 0:no previous segment
//   bool ScanLeft, ScanRight;
//   Segment(int startX, int endX, int y, var dir, bool scanLeft, bool scanRight) {
//     StartX = startX;
//     EndX = endX;
//     Y = y;
//     Dir = dir;
//     ScanLeft = scanLeft;
//     ScanRight = scanRight;
//   }

// }


//     // flag = i == 3 ? 0 : 1;
// //print('nikhil   $x1  $y1  ${_path.contains(Offset(x1, y1))}');
//     if (_path.contains(Offset(x1, y1)) ||
//             _path.contains(Offset(x1 - 1, y1)) ||
//             _path.contains(Offset(x1 + 1, y1)) ||
//             _path.contains(Offset(x1, y1 + 1)) ||
//             _path.contains(Offset(x1, y1 - 1))

//         // _path.contains(Offset(x1 - 1, y1-1)) ||
//         // _path.contains(Offset(x1 + 1, y1+1)) ||
//         // _path.contains(Offset(x1-1, y1 + 1)) ||
//         // _path.contains(Offset(x1+1, y1 - 1))
//         ) {
//       //   print('hop ');
//       return _getColor(words, x2, y2) == oldColor;
//     } else
//       return true;
//     //   print(
//     //       'flag   ${!_path.contains(Offset(x1, y1)) ? true : _getColor(words, x2, y2) == oldColor}');
//     // return !_path.contains(Offset(x1, y1))
//     //     ? true
//     //     : _getColor(words, x2, y2) == oldColor;
//   }
// }

// Color _getColor1(Uint8List bytes, double x1, double y1) {
//   // print('lk   $x1 $y1');
//   int x = x1.toInt();
//   int y = y1.toInt();
//   var byteOffset = (x + y * imageWidth) * 4;

//   var r = bytes[byteOffset];
//   var g = bytes[byteOffset + 1];
//   var b = bytes[byteOffset + 2];
//   var a = bytes[byteOffset + 3];
//   return Color.fromARGB(a, r, g, b);
// }

///////////////////////////////////////
///

//  List<Offset> _floodFill3(
//       ByteData rgb, double x, double y, Color col, Color col1) {
//     Queue<Offset> queue = new Queue();

//     queue.add(Offset(x, y));
//     _points = List.from(_points)..add(queue.first);
//     while (queue.isNotEmpty) {
//       Offset temp = queue.first;
//       //  print('before  $queue');
//       queue.removeFirst();
//       //  queue.removeLast;
//       //  queue.removeFirst;
//       print('after  $queue');
//       //  print('jio $_points');
//       if (_shouldFillColor(temp.dx + 1, temp.dy)) {
//         queue.add(Offset(temp.dx + 1, temp.dy));
//         // print('inside  $queue');
//         _points = List.from(_points)..add(Offset(temp.dx + 1, temp.dy));
//       }
//       if (_shouldFillColor(temp.dx - 1, temp.dy)) {
//         queue.add(Offset(temp.dx - 1, temp.dy));
//         _points = List.from(_points)..add(Offset(temp.dx - 1, temp.dy));
//       }
//       if (_shouldFillColor(temp.dx, temp.dy + 1)) {
//         queue.add(Offset(temp.dx, temp.dy + 1));
//         _points = List.from(_points)..add(Offset(temp.dx, temp.dy + 1));
//       }
//       if (_shouldFillColor(temp.dx, temp.dy - 1)) {
//         queue.add(Offset(temp.dx, temp.dy - 1));
//         _points = List.from(_points)..add(Offset(temp.dx, temp.dy - 1));
//       }

//       // if (_shouldFillColor(temp.dx + 1, temp.dy + 1)) {
//       //   queue.add(Offset(temp.dx + 1, temp.dy + 1));
//       //   print('inside  $queue');
//       //   _points = List.from(_points)..add(Offset(temp.dx + 1, temp.dy + 1));
//       // }
//       // if (_shouldFillColor(temp.dx - 1, temp.dy + 1)) {
//       //   queue.add(Offset(temp.dx - 1, temp.dy + 1));
//       //   _points = List.from(_points)..add(Offset(temp.dx - 1, temp.dy + 1));
//       // }
//       // if (_shouldFillColor(temp.dx + 1, temp.dy - 1)) {
//       //   queue.add(Offset(temp.dx + 1, temp.dy - 1));
//       //   _points = List.from(_points)..add(Offset(temp.dx + 1, temp.dy - 1));
//       // }
//       // if (_shouldFillColor(temp.dx - 1, temp.dy - 1)) {
//       //   queue.add(Offset(temp.dx - 1, temp.dy - 1));
//       //   _points = List.from(_points)..add(Offset(temp.dx - 1, temp.dy - 1));
//       // }
//     }
//     return _points;
//   }
