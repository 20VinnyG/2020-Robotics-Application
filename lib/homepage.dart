import 'package:flutter/material.dart';
import 'package:frc1640scoutingframework/about.dart';
import 'package:frc1640scoutingframework/scan.dart';
import 'package:frc1640scoutingframework/teleop.dart';
import 'bluealliance.dart';
import 'scoutmode.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("FRC 1640 Scouting App"),
            backgroundColor: Colors.blue[900]),
        body: new Container(
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                    child: Text('Scout Mode'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => ScoutMode()));
                    }),
                RaisedButton(
                    child: Text('Scan Mode'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => ScanMode()));
                    }),
                RaisedButton(
                    child: Text('About'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => About()));
                    }),
                RaisedButton(
                    child: Text('TBA Code'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => Bluealliance()));
                    }),
                RaisedButton(
                    child: Text('Test - Teleop'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => Teleop()));
                    }),
              ],
            ),
          ),
        ));
  }
}
