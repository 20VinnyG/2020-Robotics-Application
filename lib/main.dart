import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
        '/about': (_) => About(),
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

  String _initials, _matchNumber, _teamNumber;

  createQR(BuildContext context){
    return showDialog(context: context,builder: (context) {
      return AlertDialog(
        title: Text("Generated QR"),
        content: QrImage(
          data: "sts",
        ),
      );
    } );
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
              ),
              onSaved: (input) => _initials = input,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter the match number',
              ),
              onSaved: (input) => _matchNumber = input,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter the team number',
              ),
              onSaved: (input) => _teamNumber = input,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Generate QR"),
          onPressed: () {
            createQR(context);
          }),
    );
  }
}

class ScanMode extends StatefulWidget {
  @override
  _ScanModeState createState() => _ScanModeState();
}

class _ScanModeState extends State<ScanMode> {
  String result = "Hey there !";

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unkown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Scan Mode"), backgroundColor: Colors.blue[900]),
      body: Center(
          child: Text(
        result,
      )),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
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
