import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:frc1640scoutingframework/shot.dart';

List<Offset> points = <Offset>[];

class AutonPath extends StatefulWidget {
  final List<int> condensedPathx;
  final List<int> condensedPathy;
  final List<Shot> autonshotsList;

  @override
  AutonPathState createState() => AutonPathState();

  AutonPath({this.condensedPathx, this.condensedPathy, this.autonshotsList});
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
                  points = new List.from(points)..add(_localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) {
                points.add(null);
                Shot newShot = new Shot();
                newShot.posx = points[points.length-2].dx;
                newShot.posy = points[points.length-2].dy;                
                print(newShot.posx);
                print(newShot.posy);
                return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: Text("Enter Number of Balls Made"),
                          content: ListView(
                            children: <Widget>[
                              DropdownButton(
                                items: [
                                  DropdownMenuItem(
                                      value: int.parse("0"), child: Text("0")),
                                  DropdownMenuItem(
                                      value: int.parse("1"), child: Text("1")),
                                  DropdownMenuItem(
                                      value: int.parse("2"), child: Text("2")),
                                  DropdownMenuItem(
                                      value: int.parse("3"), child: Text("3")),
                                  DropdownMenuItem(
                                      value: int.parse("4"), child: Text("4")),
                                  DropdownMenuItem(
                                      value: int.parse("5"), child: Text("5")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    newShot.shotsMade = value;
                                  });
                                },
                                hint: Text("Balls Made"),
                                value: newShot.shotsMade,
                              ),
                              Switch(
                                value: newShot.shotType,
                                onChanged: (bool s) {
                                  setState(() {
                                    newShot.shotType = s;
                                  });
                                },
                              ),
                              RaisedButton(
                                child: Text("Done"),
                                onPressed: () {
                                  print(newShot.shotsMade);
                                  print(newShot.shotType);
                                  print(newShot.toString());
                                  widget.autonshotsList.add(newShot);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ));
                    });
              },
              child: new CustomPaint(
                painter: new AutoPath(points: points),
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
                onTap: () => points.clear()),
            SpeedDialChild(
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
                label: "Completed Path",
                onTap: () {
                  condensePoints();
                  Navigator.pop(context);
                })
          ],
        ));
  }

  condensePoints() {
    for (int i = 0; i < points.length; i+=5) {
      widget.condensedPathx.add(points[i].dx.round());
      widget.condensedPathy.add(points[i].dy.round());
    }
    if (points.last = null) {
      // != mod value - 1
      widget.condensedPathx.add(points.last.dx.round());
      widget.condensedPathy.add(points.last.dy.round());
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
