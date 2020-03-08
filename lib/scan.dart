import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:scoutmobile2020/scoutmode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoutmobile2020/types/match.dart';


final Future<SharedPreferences> _sharedPreferences =
    SharedPreferences.getInstance();

List<dynamic> data = [];

String sheetName;
String result = "Hey there !";

String _currentEventName = '';
String _matchSheetId = '';
String _shotSheetId = '';
String _pathSheetId = '';

final String _eventsParentFolderId = '1aygdfoJX-V0zoLdpnstT6B44aYWJrBjz';

final Map<String, String> matchSheetMap = {
  'Initials': 'initials',
  'Id': 'id',
  'Team Number': 'teamnumber',
  'Match Number': 'matchnumber',
  'Position': 'position',
  'Preloaded Fuel Cells': 'preloadedfuelcells',
  'Successful': 'spinoutcome',
  'Climb Time': 'climbtime',
  'Park': 'park',
  'Position Control': 'positioncontrol',
  'Color Control': 'colorcontrol',
  'General Success': 'generalsuccess',
  'Defensive Success': 'defensivesuccess',
  'Accuracy': 'accuracy',
  'Floorpickup': 'floorpickup',
  'Fouls': 'fouls',
  'Problems': 'problems'
};

final Map<String, String> shotSheetMap = {
  'Match': 'matchnumber',
  'Team Number': 'teamnumber',
  'Id': 'id',
  'Period': 'period',
  'Shots X': 'shotsx',
  'Shots Y': 'shotsy',
  'Shots Made': 'shotsmade',
  'Goal': 'goal'
};

final Map<String, String> pathSheetMap = {
  'Match': 'matchnumber',
  'Team Number': 'teamnumber',
  'Id': 'id',
  'Sequence': 'sequence',
  'Auton Path X': 'autopathx',
  'Auton Path Y': 'autopathy'
};

void _appendGeneral(SheetsApi api) async {
  print('data length: ' + data.length.toString());

  List<dynamic> payload = [];
  for (int i = 0; i < data.length; i++) {
    List<String> row = [];
    Map<String, dynamic> jsonData = data[i];
    matchSheetMap.forEach((colName, jsonName) {
      row.add(jsonData[jsonName].toString());
    });
    payload.add(row);
  }

  ValueRange vr = ValueRange.fromJson({'values': payload});
  await api.spreadsheets.values
      .append(vr, _matchSheetId, 'A:R', valueInputOption: 'USER_ENTERED');

  print('Done appending match data');
}

void _appendPath(SheetsApi api) async {
  List<dynamic> payload = [];
  for (int i = 0; i < data.length; i++) {
    Map<String, dynamic> jsonData = data[i];
    print('Shot data: ' + jsonData.toString());

    int pathLength = (jsonData['autopathx'] as List<dynamic>).length;

    List<dynamic> pathx = jsonData['autopathx'];
    List<dynamic> pathy = jsonData['autopathy'];

    for (int j = 0; j < pathLength; j++) {
      List<dynamic> row = [];

      row.add(jsonData['matchnumber']);
      row.add(jsonData['teamnumber']);
      row.add(jsonData['id']);
      row.add(j);
      row.add(pathx[j]);
      row.add(pathy[j]);

      payload.add(row);
    }
  }

  ValueRange vr = ValueRange.fromJson({'values': payload});
  await api.spreadsheets.values
      .append(vr, _pathSheetId, 'A:F', valueInputOption: 'USER_ENTERED');

  print('Done appending path data');
}

void _appendShots(SheetsApi api) async {
  List<dynamic> payload = [];
  for (int i = 0; i < data.length; i++) {
    Map<String, dynamic> jsonData = data[i];
    print('Path data: ' + jsonEncode(jsonData).toString());

    List<dynamic> autoShotsX = jsonData['autoshotsx'];
    List<dynamic> autoShotsY = jsonData['autoshotsy'];
    List<dynamic> autoShotsMade = jsonData['autoshotsmade'];
    List<dynamic> autoShotsType = jsonData['autoshotstype'];

    List<dynamic> teleShotsX = jsonData['teleopshotsx'];
    List<dynamic> teleShotsY = jsonData['teleopshotsy'];
    List<dynamic> teleShotsMade = jsonData['teleopshotsmade'];
    List<dynamic> teleShotsType = jsonData['teleopshotstype'];

    for (int j = 0; j < autoShotsX.length; j++) {
      List<dynamic> row = [];

      row.add(jsonData['matchnumber']);
      row.add(jsonData['teamnumber']);
      row.add(jsonData['id']);
      row.add('auton');

      row.add(autoShotsX[j]);
      row.add(autoShotsY[j]);
      row.add(autoShotsMade[j]);
      row.add(autoShotsType[j]);

      payload.add(row);
    }

    for (int j = 0; j < teleShotsX.length; j++) {
      List<dynamic> row = [];

      row.add(jsonData['matchnumber']);
      row.add(jsonData['teamnumber']);
      row.add(jsonData['id']);
      row.add('teleop');

      row.add(teleShotsX[j]);
      row.add(teleShotsY[j]);
      row.add(teleShotsMade[j]);
      row.add(teleShotsType[j]);

      payload.add(row);
    }
  }

  ValueRange vr = ValueRange.fromJson({'values': payload});
  await api.spreadsheets.values
      .append(vr, _shotSheetId, 'A:H', valueInputOption: 'USER_ENTERED');

  print('Done appending shot data');
}

void _appendAll() async {
  Client client = await _getGoogleClientForCurrentUser();
  SheetsApi api = SheetsApi(client);

  _appendGeneral(api);
  _appendPath(api);
  _appendShots(api);

  client.close();
}

Future<Client> _getGoogleClientForCurrentUser() async {
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
    SheetsApi.SpreadsheetsScope,
    SheetsApi.DriveFileScope
  ]);
  GoogleSignInAccount account = await googleSignIn.signIn();

  String token = (await account.authentication).accessToken;

  AccessCredentials creds = AccessCredentials(
      AccessToken('Bearer', token, DateTime.utc(DateTime.now().year + 1)),
      '', <String>[]);

  return authenticatedClient(Client(), creds);
}

// eventId is a google drive folder it
Future _loadSheetsForEvent(
    String eventDriveFolderId, BuildContext context) async {
  if (eventDriveFolderId.isEmpty) {
    print('Id empty: ' + eventDriveFolderId);
    return;
  }
  print('event id: ' + eventDriveFolderId);

  Client client = await _getGoogleClientForCurrentUser();
  DriveApi api = DriveApi(client);

  _matchSheetId = '';
  _pathSheetId = '';
  _shotSheetId = '';

  List<String> filenames = [];

  FileList eventFolders =
      await api.files.list(q: '\'${eventDriveFolderId}\' in parents');
  eventFolders.files.forEach((file) {
    if (file.name.endsWith('-matches')) {
      _matchSheetId = file.id;
      filenames.add(file.name);
    }
    if (file.name.endsWith('-paths')) {
      _pathSheetId = file.id;
      filenames.add(file.name);
    }
    if (file.name.endsWith('-shots')) {
      _shotSheetId = file.id;
      filenames.add(file.name);
    }
  });

  _sharedPreferences.then((sharedPref) {
    sharedPref.setString('lastMatchSheetId', _matchSheetId);
    sharedPref.setString('lastPathSheetId', _pathSheetId);
    sharedPref.setString('lastShotSheetId', _shotSheetId);
  });

  print('match sheet id: ' + _matchSheetId);
  print('path sheet id: ' + _pathSheetId);
  print('shot sheet id: ' + _shotSheetId);

  // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Loaded ' + filenames.length.toString() + ' sheets: ' + filenames.toString())));
}

Future<bool> _createSheetsForEvent(String eventName) async {
  if (eventName.isEmpty) {
    return false;
  }

  Client client = await _getGoogleClientForCurrentUser();
  DriveApi driveApi = DriveApi(client);
  SheetsApi api = SheetsApi(client);

  // Create a folder for the event:
  File eventFolder = await driveApi.files.create(File()
    ..name = eventName
    ..parents = [_eventsParentFolderId]
    ..mimeType = 'application/vnd.google-apps.folder');
  String eventFolderId = eventFolder.id;

  File matchSheet = await driveApi.files.create(File()
    ..name = eventName + '-matches'
    ..parents = [eventFolderId]
    ..mimeType = 'application/vnd.google-apps.spreadsheet');
  _matchSheetId = matchSheet.id;
  ValueRange matchVR = ValueRange.fromJson({
    'values': [matchSheetMap.keys.toList()]
  });
  await api.spreadsheets.values
      .append(matchVR, _matchSheetId, 'A:R', valueInputOption: 'USER_ENTERED');

  File shotSheet = await driveApi.files.create(File()
    ..name = eventName + '-shots'
    ..parents = [eventFolderId]
    ..mimeType = 'application/vnd.google-apps.spreadsheet');
  _shotSheetId = shotSheet.id;
  ValueRange shotVR = ValueRange.fromJson({
    'values': [shotSheetMap.keys.toList()]
  });
  await api.spreadsheets.values
      .append(shotVR, _shotSheetId, 'A:H', valueInputOption: 'USER_ENTERED');

  File pathSheet = await driveApi.files.create(File()
    ..name = eventName + '-paths'
    ..parents = [eventFolderId]
    ..mimeType = 'application/vnd.google-apps.spreadsheet');
  _pathSheetId = pathSheet.id;
  ValueRange pathVR = ValueRange.fromJson({
    'values': [pathSheetMap.keys.toList()]
  });
  await api.spreadsheets.values
      .append(pathVR, _pathSheetId, 'A:F', valueInputOption: 'USER_ENTERED');

  client.close();

  print('Done setup for: ' + eventName);

  return true;
}

class ScanMode extends StatefulWidget {
  @override
  _ScanModeState createState() => _ScanModeState();
}

class _ScanModeState extends State<ScanMode> {
  bool blue1status = false;
  bool blue2status = false;
  bool blue3status = false;
  bool red1status = false;
  bool red2status = false;
  bool red3status = false;
  MatchData blue1;
  MatchData blue2;
  MatchData blue3;
  MatchData red1;
  MatchData red2;
  MatchData red3;

  _ScanModeState() {
    _sharedPreferences.then((sharedPref) {
      setState(() {
        _currentEventName = sharedPref.getString('lastEventName') ?? '<none>';
        _matchSheetId = sharedPref.getString('lastMatchSheetId') ?? '';
        _pathSheetId = sharedPref.getString('lastPathSheetId') ?? '';
        _shotSheetId = sharedPref.getString('lastShotSheetId') ?? '';
      });

      print('loaded event name: ' + _currentEventName);
      print('loaded match sheet id: ' + _matchSheetId);
      print('loaded path sheet id: ' + _pathSheetId);
      print('loaded shot sheet id: ' + _shotSheetId);
    });
  }

  Future _scanQR() async {
    Map<int, dynamic> scannedData = {};
    try {
      for (;;) {
        blue1status = false;
        blue2status = false;
        blue3status = false;
        red1status = false;
        red2status = false;
        red3status = false;
        String qrResult = await BarcodeScanner.scan();
        List<int> stringBytesDecoded = base64.decode(qrResult);
        List<int> gzipBytesDecoded =
            new GZipDecoder().decodeBytes(stringBytesDecoded);
        String decodedqr = new Utf8Codec().decode(gzipBytesDecoded);

        Map<String, dynamic> json = jsonDecode(decodedqr);
        int id = json['id'];
        scannedData[id] = json;
        if (json["po"] == 0) {
          setState(() {
            print("got blue1");
            blue1 = MatchData.fromJson(json);
            blue1status = true;
          });
        } else {
          if (json["po"] == 1) {
            setState(() {
              blue2 = MatchData.fromJson(json);
              blue2status = true;
            });
          } else {
            if (json["po"] == 2) {
              setState(() {
                blue3 = MatchData.fromJson(json);
                blue3status = true;
              });
            } else {
              if (json["po"] == 3) {
                setState(() {
                  red1 = MatchData.fromJson(json);
                  red1status = true;
                });
              } else {
                if (json["po"] == 4) {
                  setState(() {
                    red2 = MatchData.fromJson(json);
                    red2status = true;
                  });
                } else {
                  if (json["po"] == 5) {
                    red3 = MatchData.fromJson(json);
                    red3status = true;
                  }
                }
              }
            }
          }
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

    data.clear();
    data.addAll(scannedData.values);
    print('Scan mode complete. Scanned ' +
        data.length.toString() +
        ' unique matches');
  }

  _buildEventLoadPrompt(BuildContext context) async {
    Client client = await _getGoogleClientForCurrentUser();
    DriveApi api = DriveApi(client);

    FileList eventFolders =
        await api.files.list(q: '\'$_eventsParentFolderId\' in parents');

    client.close();

    List<_SheetNameId> eventSheets = [];

    eventFolders.files.forEach((file) {
      print('name: ' + file.name + ' -- id: ' + file.id);
      eventSheets.add(_SheetNameId(name: file.name, id: file.id));
    });

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: Text("Select an event"),
                content: Container(
                    width: double.maxFinite,
                    child: ListView.builder(
                        itemCount: eventSheets.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Text(eventSheets[index].name),
                              onTap: () async {
                                await _loadSheetsForEvent(
                                    eventSheets[index].id, context);
                                _currentEventName = eventSheets[index].name;
                                _sharedPreferences.then((sharedPref) {
                                  sharedPref.setString(
                                      'lastEventName', _currentEventName);
                                });
                                Navigator.pop(context);
                              });
                        })));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    String eventName = '';

    print('Build start -- current event: ' + _currentEventName);

    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: new Scaffold(
          appBar: new AppBar(
              title: new Text("Scan Mode"), backgroundColor: Colors.blue[900]),
          body: Builder(
              builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Current event: $_currentEventName'),
                      TextFormField(
                        initialValue: eventName,
                        decoration:
                            const InputDecoration(labelText: 'New event name'),
                        validator: (input) =>
                            input.isEmpty ? 'Not a valid input' : null,
                        onSaved: (input) => eventName = input,
                        onFieldSubmitted: (input) => eventName = input,
                        onChanged: (input) => eventName = input,
                      ),
                      RaisedButton(
                        child: Text("Create event"),
                        onPressed: () async {
                          bool success = await _createSheetsForEvent(eventName);
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(success
                                  ? 'Created event ' + eventName
                                  : 'Couldn\'t create event ' + eventName),
                              duration: Duration(seconds: 5)));
                          eventName = '';
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                      ),
                      RaisedButton(
                          child: Text('Load event from sheets'),
                          onPressed: () async {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            await _buildEventLoadPrompt(context);
                          }),
                      RaisedButton(
                        child: Text("Push to Sheet"),
                        onPressed: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          _appendAll();
                        },
                      ),
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          RaisedButton(
                              child: Text('Red 1'),
                              color: (red1status == true)
                                  ? Colors.red
                                  : Colors.grey,
                              onPressed: () {
                                if(red1status == true) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => ScoutMode(matchDataScan: red1)));
                                }
                              }),
                          VerticalDivider(width: 5.0),
                          RaisedButton(
                              child: Text('Red 2'),
                              color: (red2status == true)
                                  ? Colors.red
                                  : Colors.grey,
                              onPressed: () {
                                if(red2status == true) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => ScoutMode(matchDataScan: red2)));
                                }
                              }),
                          VerticalDivider(width: 5.0),
                          RaisedButton(
                              child: Text('Red 3'),
                              color: (red3status == true)
                                  ? Colors.red
                                  : Colors.grey,
                              onPressed: () {
                                if(red3status == true) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => ScoutMode(matchDataScan: red3)));
                                }
                              })
                        ], mainAxisAlignment: MainAxisAlignment.center),
                        Row(children: <Widget>[
                          RaisedButton(
                              child: Text('Blue 1'),
                              color: (blue1status == true)
                                  ? Colors.blue
                                  : Colors.grey,
                              onPressed: () {
                                if(blue1status == true) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => ScoutMode(matchDataScan: blue1)));
                                }
                              }),
                          VerticalDivider(width: 5.0),
                          RaisedButton(
                              child: Text('Blue 2'),
                              color: (blue2status == true)
                                  ? Colors.blue
                                  : Colors.grey,
                              onPressed: () {
                                if(blue2status == true) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => ScoutMode(matchDataScan: blue2)));
                                }
                              }),
                          VerticalDivider(width: 5.0),
                          RaisedButton(
                              child: Text('Blue 3'),
                              color: (blue3status == true)
                                  ? Colors.blue
                                  : Colors.grey,
                              onPressed: () {
                                if(blue3status == true) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => ScoutMode(matchDataScan: blue3)));
                                }
                              })
                        ], mainAxisAlignment: MainAxisAlignment.center)
                      ], mainAxisAlignment: MainAxisAlignment.center)
                    ],
                  )),
          floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.camera_alt),
            label: Text("Scan"),
            onPressed: _scanQR,
          ),
        ));
  }
}

class _SheetNameId {
  final String name;
  final String id;

  _SheetNameId({this.name, this.id});
}
