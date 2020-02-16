import 'package:flutter/material.dart';
import "shot.dart";

double screenx = 811;
double screeny;
Paint paint = new Paint();
Canvas canvas;
Size size = new Size(screenx, screeny);

class Teleop extends StatefulWidget {
  final List<Shot> teleopshotsList;

  @override
  _TeleopState createState() => _TeleopState();

  Teleop({
    this.teleopshotsList
  });
}

bool val = true;

class _TeleopState extends State<Teleop> {

  void onTapDown(BuildContext context, TapDownDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      screenx = localOffset.dx;
      screeny = localOffset.dy;
    });
  }

  onSwitchValueChanged(bool newVal) {
    setState(() {
      val = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new GestureDetector(
      child: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage('assets/images/field.png'),
                    fit: BoxFit.cover)),
          )
        ],
      ),
      onTapDown: (TapDownDetails details) => onTapDown(context, details),
      onTap: () {
        Shot newShot = new Shot();
        newShot.posx = screenx;
        newShot.posy = screeny;
        showDialog (
            context: context,
            builder: (context) {
              return Dialog(
                  child: ListView(
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
                          widget.teleopshotsList.add(newShot);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
            });
      },
    ));
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(screenx, screeny), 25.0, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return null;
  }
}