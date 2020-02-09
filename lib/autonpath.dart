import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:frc1640scoutingframework/scoutmode.dart';

class AutonPath extends StatefulWidget {
  @override
  AutonPathState createState() => AutonPathState();
}

class AutonPathState extends State<AutonPath> {
  List<Offset> _points = <Offset>[];
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
                  _points = new List.from(_points)..add(_localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) => _points.add(null),
              child: new CustomPaint(
                painter: new AutoPath(points: _points),
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
                onTap: () => _points.clear()),
            SpeedDialChild(
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
                label: "Completed Path",
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => ScoutMode(autonpath: _points,)));
                })
          ],
        ));
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
