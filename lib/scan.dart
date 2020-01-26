import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanMode extends StatefulWidget {
  @override
  _ScanModeState createState() => _ScanModeState();
}

class _ScanModeState extends State<ScanMode> {

  String blue1;
  String blue2;
  String blue3;
  String red1;
  String red2;
  String red3;
  String packagedpayload;
  String result = "Hey there !";

  Future _scanQR() async {
    try {
      for(int i = 0; i < 5; i++) {
        String qrResult = await BarcodeScanner.scan();
        if(qrResult.contains("Blue1")) {
          blue1 = qrResult;
          print("blue1 scanned");
        }
        if(qrResult.contains("Blue2")) {
          blue2 = qrResult;
          print("blue2 scanned");
        }
        if(qrResult.contains("Blue3")) {
          blue3 = qrResult;
          print("blue3 scanned");
        }
        if(qrResult.contains("Red1")) {
          red1 = qrResult;
          print("red1 scanned");
        }
        if(qrResult.contains("Red2")) {
          red2 = qrResult;
          print("red2 scanned");
        }
        if(qrResult.contains("Red3")) {
          red3 = qrResult;
          print("red3 scanned");
        }
      }
      packagedpayload=blue1+blue2+blue3+red1+red2+red3;
      print(packagedpayload);

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
          child: RaisedButton(
            child: Text("Push to sheets"),
            onPressed: () {

            },
          )
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
    );
  }

  //void _pushtoSheets {}
}