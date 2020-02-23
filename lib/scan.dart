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

List<String> data = [];

String sheetName;
String result = "Hey there !";

String _matchSheetId = '';
String _shotSheetId = '';
String _pathSheetId = '';

final String _eventsParentFolderId = '1aygdfoJX-V0zoLdpnstT6B44aYWJrBjz';

final Map<String,String> matchSheetMap = {
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

final Map<String,String> shotSheetMap = {
	'Match': 'matchnumber',
	'Team Number': 'teamnumber',
	'Id': 'id',
	'Period': 'period',
	'Shots X': 'shotsx',
	'Shots Y': 'shotsy',
	'Shots Made': 'shotsmade',
	'Goal': 'goal'
};

final Map<String,String> pathSheetMap = {
	'Match': 'matchnumber',
	'Team Number': 'teamnumber',
	'Id': 'id',
	'Sequence': 'sequence',
	'Auton Path X': 'autopathx',
	'Auton Path Y': 'autopathy'
};

void _appendGeneral (SheetsApi api) async {
	print('data length: ' + data.length.toString());

	List<dynamic> payload = [];
	for (int i = 0; i < data.length; i++) {
		List<String> row = [];
		Map<String,dynamic> jsonData = jsonDecode(data[i]);
		matchSheetMap.forEach((colName, jsonName) {
			row.add(jsonData[jsonName].toString());
		});
		payload.add(row);
	}

	ValueRange vr = ValueRange.fromJson({ 'values': payload });
	await api.spreadsheets.values.append(vr, _matchSheetId, 'A:R', valueInputOption: 'USER_ENTERED');

	print('Done appending match data');
}

void _appendPath (SheetsApi api) async {
	List<dynamic> payload = [];
	for (int i = 0; i < data.length; i++) {
		Map<String,dynamic> jsonData = jsonDecode(data[i]);
		print('Shot data: ' + jsonData.toString());

		int pathLength = (jsonData['autopathx'] as List<dynamic>).length;
		List<dynamic> row = [];

		for (int j = 0; j < pathLength; j++) {
			pathSheetMap.forEach((colName, jsonName) {
				if (jsonName.contains('autopath')) {
					row.add(jsonData[jsonName][j]);
				} else if (colName.contains('Sequence')) {
					row.add(i);
				} else {
					row.add(jsonData[jsonName]);
				}
			});
			payload.add(row);
			row.clear();
		}

		ValueRange vr = ValueRange.fromJson({ 'values': payload 	});
		await api.spreadsheets.values.append(vr, _pathSheetId, 'A:F', valueInputOption: 'USER_ENTERED');

		print('Done appending path data');
	}
}

void _appendShots (SheetsApi api) async {
	List<dynamic> payload = [];
	for (int i = 0; i < data.length; i++) {
		Map<String,dynamic> jsonData = jsonDecode(data[i]);
		print('Path data: ' + jsonData.toString());

		int nShots = (jsonData['autoshotsx'] as List<dynamic>).length;
		List<dynamic> row = [];

		for (int j = 0; j < nShots; j++) {
			shotSheetMap.forEach((colName, jsonName) {
				if (jsonName.contains('autoshots')) {
					row.add(jsonData[jsonName][j]);
				} else {
					row.add(jsonData[jsonName]);
				}
			});
			payload.add(row);
			row.clear();
		}

		ValueRange vr = ValueRange.fromJson({ 'values': payload });
		await api.spreadsheets.values.append(vr, _shotSheetId, 'A:H', valueInputOption: 'USER_ENTERED');

		print('Done appending shot data');
	}
}

void _appendAll () async {
	Client client = await _getGoogleClientForCurrentUser();
	SheetsApi api = SheetsApi(client);
	
	_appendGeneral(api);
	_appendPath(api);
	_appendShots(api);

	client.close();
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

	FileList eventFolders = await api.files.list(q: '\'${eventDriveFolderId}\' in parents');
	eventFolders.files.forEach((file) {
		if (file.name.endsWith('-matches')) { _matchSheetId = file.id; filenames.add(file.name); }
		if (file.name.endsWith('-paths')) { _pathSheetId = file.id; filenames.add(file.name); }
		if (file.name.endsWith('-shots')) { _shotSheetId = file.id; filenames.add(file.name); }
	});

	print('match sheet id: ' + _matchSheetId);
	print('path sheet id: ' + _pathSheetId);
	print('shot sheet id: ' + _shotSheetId);

	// Scaffold.of(context).showSnackBar(SnackBar(content: Text('Loaded ' + filenames.length.toString() + ' sheets: ' + filenames.toString())));
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

class ScanMode extends StatefulWidget {
	@override
	_ScanModeState createState() => _ScanModeState();
}

class _ScanModeState extends State<ScanMode> {
	Future _scanQR() async {
		try {
			data.clear();
			print('Cleared scan data: ' + data.length.toString());
			for (int i = 0; i < 6; i++) {
				String qrResult = await BarcodeScanner.scan();
				List<int> stringBytesDecoded = base64.decode(qrResult);
				List<int> gzipBytesDecoded = new GZipDecoder().decodeBytes(stringBytesDecoded);
				String decodedqr = new Utf8Codec().decode(gzipBytesDecoded);
				data.add(decodedqr);
				print("transmitted: " + qrResult.length.toString() + " -- decoded: " + decodedqr.length.toString());
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

	_buildEventLoadPrompt (BuildContext context) async {
		Client client = await _getGoogleClientForCurrentUser();
		DriveApi api = DriveApi(client);

		FileList eventFolders = await api.files.list(q: '\'${_eventsParentFolderId}\' in parents');

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
												await _loadSheetsForEvent(eventSheets[index].id, context);
												Navigator.pop(context);
											}
										);
									}
								)
						));
				});	
			});
	}

	@override
	Widget build(BuildContext context) {
		String eventName = '';

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
									Scaffold.of(context).showSnackBar(SnackBar(content: Text(success ? 'Created event ' + eventName : 'Couldn\'t create event ' + eventName), duration: Duration(seconds: 5)));
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
									_appendAll();
								},
							)
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