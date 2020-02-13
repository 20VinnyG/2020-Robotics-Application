import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:frc1640scoutingframework/scoutmode.dart';

class AutonPath extends StatefulWidget {
  final List<Offset> condensedPath;
  final List<Offset> points;

  @override
  AutonPathState createState() => AutonPathState();

  AutonPath({
    this.condensedPath,
    this.points
  });
}

class AutonPathState extends State<AutonPath> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(children: <Widget>[
          Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage('assets/images/field.png'),
                    fit: BoxFit.cover)),
          ),
          new GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox object = context.findRenderObject();
                  Offset _localPosition =
                      object.globalToLocal(details.globalPosition);
                  widget.points = new List.from(widget.points)..add(_localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) => widget.points.add(null),
              child: new CustomPaint(
                painter: new AutoPath(points: widget.points),
                size: Size.infinite,
              )),
        ]),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
                backgroundColor: Colors.red,
                child: Icon(Icons.clear),
                label: "Clear Path",
                onTap: () => widget.points.clear()),
            SpeedDialChild(
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
                label: "Completed Path",
                onTap: () {
                  print(widget.points.length);
                  //Navigator.pop(context);
                  }
                  )
          ],
        ));
  }
  condensePoints() {
    for(int i=0; i<widget.points.length; i+=5) {
      widget.condensedPath.add(widget.points[i]);
    }
    if(widget.points.length % 5 != 4) { // != mod value - 1
      widget.condensedPath.add(widget.points.last);
    }
}
}


class AutoPath extends CustomPainter {
  List<Offset> points;
  AutoPath({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(AutoPath oldDelegate) => oldDelegate.points != points;
}
