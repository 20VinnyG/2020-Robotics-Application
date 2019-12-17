import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FRC 1640 Scouting App',
      home: Homepage(),
      routes: {
        '/scoutMode': (_) => ScoutMode(),
        '/scanMode': (_) => ScanMode(),
        'about': (_) => About(),
      },
    );
  }
}

class Homepage extends StatelessWidget {
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
                      Navigator.of(context).pushNamed('/scoutMode');
                    }),
                RaisedButton(
                    child: Text('Scan Mode'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/scanMode');
                    }),
                RaisedButton(
                    child: Text('About'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/about');
                    }),
              ],
            ),
          ),
        ));
  }
}

class ScoutMode extends StatelessWidget {

  List<DropdownMenuItem<int>> listDrop = [];

  void loadData() {
    listDrop = [];
    listDrop.add(new DropdownMenuItem(
      child: new Text('Blue 1'),
      value: 1,
    ));
    listDrop.add(new DropdownMenuItem(
      child: new Text('Blue 2'),
      value: 2,
    ));
    listDrop.add(new DropdownMenuItem(
      child: new Text('Blue 3'),
      value: 3,
    ));
        listDrop.add(new DropdownMenuItem(
      child: new Text('Red 1'),
      value: 4,
    ));
    listDrop.add(new DropdownMenuItem(
      child: new Text('Red 2'),
      value: 5,
    ));
    listDrop.add(new DropdownMenuItem(
      child: new Text('Red 3'),
      value: 6,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Scout Mode"), backgroundColor: Colors.blue[900]),
        body: new Container(
            child: ListView(
          children: <Widget>[
            TextFormField(
                decoration: const InputDecoration(
              hintText: 'Enter your initials',
            )),
            TextFormField(
                decoration: const InputDecoration(
              hintText: 'Enter the match number',
            )),
            TextFormField(
                decoration: const InputDecoration(
              hintText: 'Enter the team number',
            )),
            DropdownButton(
              items: listDrop,
              onChanged: null, 
            )
          ],
        )));
  }
}

class ScanMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Scan Mode"), backgroundColor: Colors.blue[900]),
    );
  }
}

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("About"), backgroundColor: Colors.blue[900]),
    );
  }
}
