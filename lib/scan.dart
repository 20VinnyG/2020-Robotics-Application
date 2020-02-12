import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';

String sheetName;
String blue1;
String blue2;
String blue3;
String red1;
String red2;
String red3;
String result = "Hey there !";

const _credentials = r'''{
  "type": "service_account",
  "project_id": "scout-mobile-2020",
  "private_key_id": "5b1b348fc375c149e30286befda456f65368972b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCx0beG+ts1jYT7\npCOaW52DAU/i9nPx1Bn9W+/VwGknYEs0sPzy+BwFNujsdeTKBYsjRTpB+048/wdb\nVASsPXVnXgkbf8ZhNCG/9mbm8PSIIE+SFyW26/dD7IYwwWlvKlDuTPSCMe9L80GA\nmUzoWXrtI/7+NnPa51J5K/oaXaULLjoIVFJVcPOqYMBtE2ftTXEjr21zn7QxI4cE\na5t09p8vZgVIF6UDjgFiFJ5S/OMbZsc6qo69HbLBy2JAb0fEXcfKwBpyv/vYPsuk\nLAf7vQwpYna51Aess6qCu7c3WsOyahK1WjKRdeb2bzY3zfAflwdiX656uUAUu8sN\nOkXFAATvAgMBAAECggEARgA4nwcPF7BsCwItT91EDygLkl4R+7/TMWWpbzzNSIaE\nZKxOD7ozkavxmvC4Tf1LrmlYy1PKk4GUHFRheIrDNpuSu0QcTPTQWnj+PmjZ4uLR\nYEIDg1S2JQOuOfBR+MSwUndyA/TzbrNG9IClAY0EMumqPtoh1qmc0n3I+esmh1UV\nyMohHKbZHroTzdwtd0pKzhWpyNJ1gVWdzisECm7f9XeNtG/UQ9R+4WhjFbHNG9ie\nbN8xegAs3xoZ16SdlsrBzyuo8RgqqeSGL0xIDzuAf4k/IEXmeaxhmIlU8OFIUhzZ\nNluxxpT4uhowp6XrORHvgtrOPawFvhu7Nq2jcbjxdQKBgQDchJQQ9m2f1V4AG+B/\nEuCQPOTDg3UXxYm9nVieQCDA5K5pLSi0nbVj+KkqfNefnf6sbIjd4IP0veSPV+2z\nXfHfPsL4NgItO8nP9Nka/kku4T3aT1D46OXA9s4eR9ZLzSiYaMxemEk1k28mmcZ7\nI2HOUZ4/WeT37/EJFlm8zhZkWwKBgQDOblLnTN1lNfzvrcC2FY1Mxu9rL/OyGTOf\nGrscoIWmSO+clOM7tty4hYDSL3h431TNaxomsQiW9jk45+qLXIe3Nkbtc3qRiBQy\nVfNkQ/FRxMY5lMHpDtdNKoSYjS55+bHeXf00J/FRSjRNI7Tm0DB5XxUAfFalkHup\nLa0wXcg1/QKBgFG1AhPi6y2M5n6N1bnf6bsoBO94lvtO40GRupMwWbJ/SSyJYgrC\nYMKBEVU/2rk21nVW5cOoe9xEPBrszpNmXMeGPsGvaVEPVTCrnYIF9GHdbYilWPBR\ng0fjau4HWhzOEJugQRFPxdiHH2kjE0rvCj9jOIpqqY9ApYPjdy6hAeT/AoGACEfq\nsXam5vl8dQzuTx+cNHlCf3VD/GAAbyB+Yw6Zbes9GXXri6ixQAGzAjt/RLIIz9i9\nCtJNOukTsJG1GfQTSak2vS3Fu/LOhJpoEhyboKEZJpQuFzBOOL085nW7aI84sGfq\n0V3M02r7oCCPkDbHywaibAuQ2kFqhIXdjbQlZO0CgYBw6bamavKA7Oi1bofJxJTI\nDEoYOwcs8kIjFAbW+tsAb8WIynM5w77OEYuQ8b+XiI5Wgx4LtF79TLjEWocGGK1G\npTNHdmyWJZAmKvJdUu8yAILIUHOjMt0/Dyun0p1Mz/MPyf1OBiux+N5unzH6+9uo\nMiI14ONzmMiZTzMPf7t6Dw==\n-----END PRIVATE KEY-----\n",
  "client_email": "id-640scribe@scout-mobile-2020.iam.gserviceaccount.com",
  "client_id": "107520628007120267721",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/id-640scribe%40scout-mobile-2020.iam.gserviceaccount.com"
}
''';

String _spreadsheetId = '1K3AQE7kr5u0Z-_c-_YGsHVGHImtGfy47bBikxvjjdUQ';


void _createSpreadSheet() async {
  final gsheets = GSheets(_credentials);
  final ss = await gsheets.spreadsheet(_spreadsheetId);
  var sheet = ss.worksheetByTitle("Sheet1");
  final sheetinitializer = ['Initials', 'Position', 'Match Number', 'Team Number', 'Initiation Line Position', 'Preloaded Fuel Cells', 'ClimbTime', 'Park', 'General Success', 'Defensive Success', 'Accuracy', 'Floorpickup', 'Fouls', 'Problems'];
  await sheet.values.insertRow(1, sheetinitializer);
}

void _appendValues() async {
  final gsheets = GSheets(_credentials);
  final ss = await gsheets.spreadsheet(_spreadsheetId);
  var sheet = ss.worksheetByTitle("Sheet1");

  Map<String, dynamic> preb1 = jsonDecode(blue1);
  Map<String, dynamic> preb2 = jsonDecode(blue2);
  Map<String, dynamic> preb3 = jsonDecode(blue3);
  Map<String, dynamic> prer1 = jsonDecode(red1);
  Map<String, dynamic> prer2 = jsonDecode(red2);
  Map<String, dynamic> prer3 = jsonDecode(red3);

  List<dynamic> b1 = preb1.values.toList();
  List<dynamic> b2 = preb2.values.toList();
  List<dynamic> b3 = preb3.values.toList();
  List<dynamic> r1 = prer1.values.toList();
  List<dynamic> r2 = prer2.values.toList();
  List<dynamic> r3 = prer3.values.toList();

  var payloadb1 = new List<String>.from(b1);
  var payloadb2 = new List<String>.from(b2);
  var payloadb3 = new List<String>.from(b3);
  var payloadr1 = new List<String>.from(r1);
  var payloadr2 = new List<String>.from(r2);
  var payloadr3 = new List<String>.from(r3);

  await sheet.values.insertRow(1, payloadb1);
  await sheet.values.insertRow(2, payloadb2);
  await sheet.values.insertRow(3, payloadb3);
  await sheet.values.insertRow(4, payloadr1);
  await sheet.values.insertRow(5, payloadr2);
  await sheet.values.insertRow(6, payloadr3);

}
 
class ScanMode extends StatefulWidget {
  @override
  _ScanModeState createState() => _ScanModeState();
}

class _ScanModeState extends State<ScanMode> {

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
      body: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter sheet ID',
            ), 
            validator: (input) =>
              input.isEmpty ? 'Not a valid input' : null,
            onSaved: (input) => _spreadsheetId = input,
            onFieldSubmitted: (input) =>
              _spreadsheetId = input,
            onChanged: (input) => _spreadsheetId = input,
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter ',
            ), 
            validator: (input) =>
              input.isEmpty ? 'Not a valid input' : null,
            onSaved: (input) => sheetName = input,
            onFieldSubmitted: (input) =>
              sheetName = input,
            onChanged: (input) => sheetName = input,
          ),
          RaisedButton(
            child: Text("Create Sheet"),
            onPressed: () {
              _createSpreadSheet();
            },
          ),
          RaisedButton(
            child: Text("Create Sheet"),
            onPressed: () {
              _appendValues();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
    );
  }
}