import 'package:flutter/material.dart';

class Teleop extends StatefulWidget {
  @override
  _TeleopState createState() => _TeleopState();
}

class _TeleopState extends State<Teleop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            title: new Text("Scout Mode"), backgroundColor: Colors.blue[900]),
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
        onTap: () {
          return showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: Text("Enter Number of Balls Made"),
              content: DropdownButton(
                          items: [
                            DropdownMenuItem(
                                value: int.parse("1"), child: Text("Blue1")),
                            DropdownMenuItem(
                                value: int.parse("2"), child: Text("Blue2")),
                            DropdownMenuItem(
                                value: int.parse("3"), child: Text("Blue3")),
                            DropdownMenuItem(
                                value: int.parse("4"), child: Text("Red1")),
                            DropdownMenuItem(
                                value: int.parse("5"), child: Text("Red2")),
                            DropdownMenuItem(
                                value: int.parse("6"), child: Text("Red3")),
                          ],
                          hint: Text("Balls Made"),
                          //value: newMatch.position,
                        ),
            );
          });
        },
        ));
  }
}
