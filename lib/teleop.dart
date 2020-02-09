import 'package:flutter/material.dart';
import "shot.dart";

double screenx;
double screeny;
bool val = true;
List<Shot> shots = new List();

class Teleop extends StatefulWidget {
  @override
  _TeleopState createState() => _TeleopState();
}

class _TeleopState extends State<Teleop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Stack(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('assets/images/field.png'),
                  fit: BoxFit.cover)),
        ),
        new GestureDetector(
          onTapDown: (TapDownDetails details) => onTapDown(context, details),
          onTapUp: 
          input(),
          /*onTap: () {
            input();
          },*/
          child: new CustomPaint(
              painter: new TeleopShots(shots: shots), size: Size.infinite),
        )
      ],
    ));
  }

  void onTapDown(BuildContext context, TapDownDetails details) {
    print('${details.globalPosition}');
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      screenx = localOffset.dx;
      screeny = localOffset.dy;
    });
  }

  input() {
    Shot newShot = new Shot();
    newShot.posx = screenx;
    newShot.posy = screeny;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Enter Number of Balls Made"),
              content: ListView(
                children: <Widget>[
                  DropdownButton(
                    items: [
                      DropdownMenuItem(value: int.parse("0"), child: Text("0")),
                      DropdownMenuItem(value: int.parse("1"), child: Text("1")),
                      DropdownMenuItem(value: int.parse("2"), child: Text("2")),
                      DropdownMenuItem(value: int.parse("3"), child: Text("3")),
                      DropdownMenuItem(value: int.parse("4"), child: Text("4")),
                      DropdownMenuItem(value: int.parse("5"), child: Text("5")),
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
                    onChanged: (newVal) {
                      setState(() {
                        newShot.shotType = newVal;
                      });
                    },
                  ),
                  RaisedButton(
                      child: Text("Done"),
                      onPressed: () {
                        shots.add(newShot);
                      }),
                ],
              ));
        });
  }

  onSwitchValueChanged(bool newVal) {
    setState(() {
      val = newVal;
    });
  }
}

class TeleopShots extends CustomPainter {
  List<Shot> shots;
  TeleopShots({this.shots});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    canvas.drawCircle(Offset(screenx, screeny), 15.0, paint);
  }

  @override
  bool shouldRepaint(TeleopShots oldDelegate) => oldDelegate.shots != shots;
}
