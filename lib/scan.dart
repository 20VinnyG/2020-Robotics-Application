import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:scoutmobile2020/service/qr.dart';
import 'package:scoutmobile2020/types/match.dart';
import 'package:scoutmobile2020/types/shot.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

List<dynamic> data = [];

String result = '';

String _currentEventName = '';
String _matchSheetId = '';
String _shotSheetId = '';
String _pathSheetId = '';

final String _eventsParentFolderId = '1aygdfoJX-V0zoLdpnstT6B44aYWJrBjz';

final Map<String,String> matchSheetMap = {
		'Initials': 'in',
		'Id': 'id',
		'Team Number': 'tn',
		'Match Number': 'mn',
		'Position': 'po',
		'Preloaded Fuel Cells': 'fc',
		'Climb Time': 'ct',
		'Park': 'pa',
		'Position Control': 'sp:pc',
		'Rotation Control': 'sp:rc',
		'General Success': 'gs',
		'Defensive Success': 'ds',
		'Accuracy': 'ac',
		'Floorpickup': 'fp',
		'Fouls': 'fo',
		'Problems': 'pr'
};

final Map<String,String> shotSheetMap = {
	'Match': '',
	'Team Number': '',
	'Id': '',
	'Period': '',
	'Shots X': '',
	'Shots Y': '',
	'Shots Made': '',
	'High Goal': ''
};

final Map<String,String> pathSheetMap = {
	'Match': '',
	'Team Number': '',
	'Id': '',
	'Sequence': '',
	'Auton Path X': '',
	'Auton Path Y': ''
};

Future _appendMatch (SheetsApi api) async {
	print('data length: ' + data.length.toString());

	List<dynamic> payload = [];
	for (int i = 0; i < data.length; i++) {
		print('processing scanned qr: ' + i.toString());

		List<dynamic> row = [];
		Map<String,dynamic> jsonData = data[i];

		matchSheetMap.forEach((colName, jsonName) {
			List<String> keyPath = jsonName.split(":");
			dynamic value = jsonData[keyPath[0]];
			for (int j = 1; j < keyPath.length; j++) {
				value = value[keyPath[j]];
			}
			row.add(value);
		});

		print('row: ' + row.toString());

		payload.add(row);
	}

	print('payload: ' + payload.toString());

	ValueRange vr = ValueRange.fromJson({ 'values': payload });
	return api.spreadsheets.values.append(vr, _matchSheetId, 'A:P', valueInputOption: 'USER_ENTERED');
}

Future _appendPath (SheetsApi api) async {
	List<dynamic> payload = [];

	for (int i = 0; i < data.length; i++) {
		MatchData matchData = MatchData.fromJson(data[i]);

		List<Offset> autopath = matchData.autopathpointscondensed;
		for (int j = 0; j < autopath.length; j++) {
			List<dynamic> row = [];

			row.add(matchData.matchNumber);
			row.add(matchData.teamNumber);
			row.add(matchData.id);
			row.add(j);
			row.add(autopath[j].dx);
			row.add(autopath[j].dy);

			payload.add(row);
		}
	}

	ValueRange vr = ValueRange.fromJson({ 'values': payload 	});
	return api.spreadsheets.values.append(vr, _pathSheetId, 'A:F', valueInputOption: 'USER_ENTERED');
}

Future _appendShots (SheetsApi api) async {
	List<dynamic> payload = [];

	for (int i = 0; i < data.length; i++) {
		MatchData matchData = MatchData.fromJson(data[i]);

		print('MatchData: ' + matchData.toJson().toString());

		List<Shot> autoShots = matchData.autoshots;
		for (int j = 0; j < autoShots.length; j++) {
			List<dynamic> row = [];

			row.add(matchData.matchNumber);
			row.add(matchData.teamNumber);
			row.add(matchData.id);
			row.add('auton');
			row.add(autoShots[j].pos.dx);
			row.add(autoShots[j].pos.dy);
			row.add(autoShots[j].shotsMade);
			row.add(autoShots[j].shotType);

			payload.add(row);
		}

		List<Shot> teleopShots = matchData.teleopshots;
		for (int j = 0; j < teleopShots.length; j++) {
			List<dynamic> row = [];

			row.add(matchData.matchNumber);
			row.add(matchData.teamNumber);
			row.add(matchData.id);
			row.add('teleop');
			row.add(teleopShots[j].pos.dx);
			row.add(teleopShots[j].pos.dy);
			row.add(teleopShots[j].shotsMade);
			row.add(teleopShots[j].shotType);

			payload.add(row);
		}
	}

	ValueRange vr = ValueRange.fromJson({ 'values': payload });
	return api.spreadsheets.values.append(vr, _shotSheetId, 'A:H', valueInputOption: 'USER_ENTERED');
}

void _appendAll (BuildContext context) async {
	Client client = await _getGoogleClientForCurrentUser();
	SheetsApi api = SheetsApi(client);

	print('name: ' + _currentEventName + '; match: ' + _matchSheetId + '; shot: ' + _shotSheetId + '; path: ' + _pathSheetId);
	if (_currentEventName.isEmpty || _matchSheetId.isEmpty || _shotSheetId.isEmpty || _pathSheetId.isEmpty) {
		await _buildEventLoadPrompt(context);
	}

	List<Widget> statusBoxWidgets = [];

	try {
		await _appendMatch(api);
		statusBoxWidgets.add(Text('Success writing match data\n\n', textAlign: TextAlign.left));
	} catch (err) {
		statusBoxWidgets.add(Text('Failure writing match data\n', textAlign: TextAlign.left, style: TextStyle(color: Colors.red)));
		statusBoxWidgets.add(Text(err.toString() + '\n\n', textAlign: TextAlign.left));
	}

	try {
		await _appendPath(api);
		statusBoxWidgets.add(Text('Success writing path data\n\n', textAlign: TextAlign.left));
	} catch (err) {
		statusBoxWidgets.add(Text('Failure writing path data\n', textAlign: TextAlign.left, style: TextStyle(color: Colors.red)));
		statusBoxWidgets.add(Text(err.toString() + '\n\n', textAlign: TextAlign.left));
	}

	try {
		await _appendShots(api);
		statusBoxWidgets.add(Text('Success writing shot data\n\n', textAlign: TextAlign.left));
	} catch (err) {
		statusBoxWidgets.add(Text('Failure writing shot data\n', textAlign: TextAlign.left, style: TextStyle(color: Colors.red)));
		statusBoxWidgets.add(Text(err.toString() + '\n\n', textAlign: TextAlign.left));
	}

	statusBoxWidgets.add(
		RaisedButton(
			child: Text('Close'),
			onPressed: () { Navigator.pop(context); }
		)
	);

	client.close();

	showDialog(
			context: context,
			builder: (context) {
				return Builder(builder: (context) {
					return AlertDialog(
						title: Text('Status for event: $_currentEventName'),
						content: Column(
							children: statusBoxWidgets,
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.start,
						)
				);
			});
		});
}

Future<Client> _getGoogleClientForCurrentUser () async {
	GoogleSignIn googleSignIn = GoogleSignIn(
		scopes: [ 'email', 'https://www.googleapis.com/auth/contacts.readonly', SheetsApi.SpreadsheetsScope, SheetsApi.DriveFileScope ]
	);
	GoogleSignInAccount account = await googleSignIn.signIn();

	String token = (await account.authentication).accessToken;

	AccessCredentials creds = AccessCredentials(
		AccessToken('Bearer', token, DateTime.utc(DateTime.now().year + 1)),
		'', <String>[]
	);

	return authenticatedClient(Client(), creds);
}

// eventId is a google drive folder it
Future _loadSheetsForEvent (String eventDriveFolderId, BuildContext context) async {
	if (eventDriveFolderId.isEmpty) { print('Id empty: ' + eventDriveFolderId); return; }
	print('event id: ' + eventDriveFolderId);

	Client client = await _getGoogleClientForCurrentUser();
	DriveApi api = DriveApi(client);

	_matchSheetId = '';
	_pathSheetId = '';
	_shotSheetId = '';

	List<String> filenames = [];

	FileList eventFolders = await api.files.list(q: '\'$eventDriveFolderId\' in parents');
	eventFolders.files.forEach((file) {
		if (file.name.endsWith('-matches')) { _matchSheetId = file.id; filenames.add(file.name); }
		if (file.name.endsWith('-paths')) { _pathSheetId = file.id; filenames.add(file.name); }
		if (file.name.endsWith('-shots')) { _shotSheetId = file.id; filenames.add(file.name); }
	});

	_sharedPreferences.then((sharedPref) {
		sharedPref.setString('lastMatchSheetId', _matchSheetId);
		sharedPref.setString('lastPathSheetId', _pathSheetId);
		sharedPref.setString('lastShotSheetId', _shotSheetId);
	});

	print('match sheet id: ' + _matchSheetId);
	print('path sheet id: ' + _pathSheetId);
	print('shot sheet id: ' + _shotSheetId);

	 Scaffold.of(context).showSnackBar(SnackBar(content: Text('Loaded ' + filenames.length.toString() + ' sheets: ' + filenames.toString()), duration: Duration(seconds: 3)));
}

Future<bool> _createSheetsForEvent (String eventName) async {
	if (eventName.isEmpty) { return false; }

	Client client = await _getGoogleClientForCurrentUser();
	DriveApi driveApi = DriveApi(client);
	SheetsApi api = SheetsApi(client);

	// Create a folder for the event:
	File eventFolder = await driveApi.files.create(
		File()
			..name = eventName
			..parents = [_eventsParentFolderId]
			..mimeType = 'application/vnd.google-apps.folder'
	);
	String eventFolderId = eventFolder.id;

	File matchSheet = await driveApi.files.create(
		File()
			..name = eventName + '-matches'
			..parents = [eventFolderId]
			..mimeType = 'application/vnd.google-apps.spreadsheet'
	);
	_matchSheetId = matchSheet.id;
	ValueRange matchVR = ValueRange.fromJson({
		'values': [ matchSheetMap.keys.toList() ]
	});
	await api.spreadsheets.values.append(matchVR, _matchSheetId, 'A:R', valueInputOption: 'USER_ENTERED');

	File shotSheet = await driveApi.files.create(
		File()
			..name = eventName + '-shots'
			..parents = [eventFolderId]
			..mimeType = 'application/vnd.google-apps.spreadsheet'
	);
	_shotSheetId = shotSheet.id;
	ValueRange shotVR = ValueRange.fromJson({
		'values': [ shotSheetMap.keys.toList() ]
	});
	await api.spreadsheets.values.append(shotVR, _shotSheetId, 'A:H', valueInputOption: 'USER_ENTERED');

	File pathSheet = await driveApi.files.create(
		File()
			..name = eventName + '-paths'
			..parents = [eventFolderId]
			..mimeType = 'application/vnd.google-apps.spreadsheet'
	);
	_pathSheetId = pathSheet.id;
	ValueRange pathVR = ValueRange.fromJson({
		'values': [ pathSheetMap.keys.toList() ]
	});
	await api.spreadsheets.values.append(pathVR, _pathSheetId, 'A:F', valueInputOption: 'USER_ENTERED');

	client.close();

	print('Done setup for: ' + eventName);

	return true;
}

Future _buildEventLoadPrompt (BuildContext altContext) async {
	Client client = await _getGoogleClientForCurrentUser();
	DriveApi api = DriveApi(client);

	FileList eventFolders = await api.files.list(q: '\'$_eventsParentFolderId\' in parents');

	client.close();

	List<_SheetNameId> eventSheets = [];

	eventFolders.files.forEach((file) {
		print('name: ' + file.name + ' -- id: ' + file.id);
		eventSheets.add(_SheetNameId(name: file.name, id: file.id));
	});

	return showDialog(
			context: altContext,
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
											await _loadSheetsForEvent(eventSheets[index].id, altContext);
											_currentEventName = eventSheets[index].name;
											_sharedPreferences.then((sharedPref) { sharedPref.setString('lastEventName', _currentEventName); });
											Navigator.pop(context);
										}
									);
								}
							)
					));
			});
		});
}

class ScanMode extends StatefulWidget {
	@override
	_ScanModeState createState() => _ScanModeState();
}

class _ScanModeState extends State<ScanMode> {

	_ScanModeState () {
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
		Map<int,dynamic> scannedData = {};

		try {
			for (;;) {
				String qrData = await QrTools.readCompressedQrCode();
				Map<String,dynamic> json = jsonDecode(qrData);
				int id = json['id'];
				scannedData[id] = json;
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
		print('Scan mode complete. Scanned ' + data.length.toString() + ' unique matches');
	}

	@override
	Widget build (BuildContext context) {
		String eventName = '';

		print('Build start -- current event: ' + _currentEventName);

		return GestureDetector(
			onTap: () {
				FocusScopeNode currentFocus = FocusScope.of(context);
				if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
			},
			child: new Scaffold(
				appBar: new AppBar(
						title: new Text("Scan Mode"), backgroundColor: Colors.blue[900]),
				body: Builder(builder: (context) =>
					Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Text('Current event: $_currentEventName'),
							TextFormField(
								initialValue: eventName,
								decoration: const InputDecoration(labelText: 'New event name'),
								validator: (input) => input.isEmpty ? 'Not a valid input' : null,
								onSaved: (input) => eventName = input,
								onFieldSubmitted: (input) => eventName = input,
								onChanged: (input) => eventName = input,
							),
							RaisedButton(
								child: Text("Create event"),
								onPressed: () async {
									bool success = await _createSheetsForEvent(eventName);
									Scaffold.of(context).showSnackBar(SnackBar(content: Text(success ? 'Created event ' + eventName : 'Couldn\'t create event ' + eventName), duration: Duration(seconds: 3)));
									eventName = '';
									FocusScopeNode currentFocus = FocusScope.of(context);
									if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
								},
							),
							RaisedButton(
								child: Text('Load event from sheets'),
								onPressed: () async {
									FocusScopeNode currentFocus = FocusScope.of(context);
									if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
									await _buildEventLoadPrompt(context);
								}
							),
							RaisedButton(
								child: Text("Push to Sheet"),
								onPressed: () {
									FocusScopeNode currentFocus = FocusScope.of(context);
									if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
									_appendAll(context);
								},
							),
						],
					)
				),
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

	_SheetNameId({
		this.name,
		this.id
	});
}