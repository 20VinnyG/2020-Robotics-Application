import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

List<String> data = [];

String sheetName;
String result = "Hey there !";

String _spreadsheetId = '1K3AQE7kr5u0Z-_c-_YGsHVGHImtGfy47bBikxvjjdUQ';

String _matchSheetId = '';
String _shotSheetId = '';
String _pathSheetId = '';

final Map<String,String> matchSheetMap = {
		'Initials': 'initials',
		'Id': 'id',
		'Team Number': 'teamnumber',
		'Match Number': 'matchnumber',
		'Position': 'position',
		'Preloaded Fuel Cells': 'preloadedfuelcells',
		'Control Type': 'rotationControl',
		'Successful': 'spinoutcome',
		'Climb Time': 'climbtime',
		'Park': 'park',
		'Rotation Control': 'rotationControl',
		'Spin Outcome': 'spinoutcome',
		'General Success': 'generalsuccess',
		'Defensive Success': 'defensivesuccess',
		'Accuracy': 'accuracy',
		'Floorpickup': 'floorpickup',
		'Fouls': 'fouls',
		'Problems': 'problems'
};

final Map<String,String> shotSheetMap = {
	'Match': 'match',
	'Robot': 'robot',
	'Id': 'id',
	'Period': 'period',
	'Shots X': 'shotsx',
	'Shots Y': 'shotsy',
	'Shots Made': 'shotsmade',
	'Goal': 'goal'
};

final Map<String,String> pathSheetMap = {
	'Match': 'match',
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
				} else {
					row.add(jsonData[jsonName]);
				}
			});
			payload.add(row);
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
		}

		ValueRange vr = ValueRange.fromJson({ 'values': payload });
		await api.spreadsheets.values.append(vr, _shotSheetId, 'A:F', valueInputOption: 'USER_ENTERED');

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

// void _testSheetsApi () async {
// 	Client client = await _getGoogleClientForCurrentUser();

// 	SheetsApi sheetsApi = SheetsApi(client);
// 	Spreadsheet sheet = await sheetsApi.spreadsheets.create(Spreadsheet.fromJson({
// 		'properties': {
// 			'title': 'nvk-test-sheet'
// 		}
// 	}));
// 	String sheetId = sheet.spreadsheetId;

// 	ValueRange vr = ValueRange.fromJson({
// 		'values': [
// 			['A', 'B', 'C', 'D', 'E'],
// 			['F', 'G', 'H', 'I', 'J']
// 		]
// 	});

// 	await sheetsApi.spreadsheets.values.append(vr, sheetId, 'A:E', valueInputOption: 'USER_ENTERED');

// 	client.close();
// }

void _createSheetsForEvent (String eventName) async {
	Client client = await _getGoogleClientForCurrentUser();
	SheetsApi api = SheetsApi(client);

	Spreadsheet matchSheet = await api.spreadsheets.create(Spreadsheet.fromJson({
		'properties': {
			'title': '${eventName}-matches'
		}
	}));
	_matchSheetId = matchSheet.spreadsheetId;
	ValueRange matchVR = ValueRange.fromJson({
		'values': [ matchSheetMap.keys.toList() ]
	});
	await api.spreadsheets.values.append(matchVR, _matchSheetId, 'A:R', valueInputOption: 'USER_ENTERED');

	Spreadsheet shotSheet = await api.spreadsheets.create(Spreadsheet.fromJson({
		'properties': {
			'title': '${eventName}-shots'
		}
	}));
	_shotSheetId = shotSheet.spreadsheetId;
	ValueRange shotVR = ValueRange.fromJson({
		'values': [ shotSheetMap.keys.toList() ]
	});
	await api.spreadsheets.values.append(shotVR, _shotSheetId, 'A:H', valueInputOption: 'USER_ENTERED');

	Spreadsheet pathSheet = await api.spreadsheets.create(Spreadsheet.fromJson({
		'properties': {
			'title': '${eventName}-paths'
		}
	}));
	_pathSheetId = pathSheet.spreadsheetId;
	ValueRange pathVR = ValueRange.fromJson({
		'values': [ pathSheetMap.keys.toList() ]
	});
	await api.spreadsheets.values.append(pathVR, _pathSheetId, 'A:F', valueInputOption: 'USER_ENTERED');

	client.close();

	print('Done setup for: ' + eventName);
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
						validator: (input) => input.isEmpty ? 'Not a valid input' : null,
						onSaved: (input) => _spreadsheetId = input,
						onFieldSubmitted: (input) => _spreadsheetId = input,
						onChanged: (input) => _spreadsheetId = input,
					),
					TextFormField(
						decoration: const InputDecoration(
							hintText: 'Enter ',
						),
						validator: (input) => input.isEmpty ? 'Not a valid input' : null,
						onSaved: (input) => sheetName = input,
						onFieldSubmitted: (input) => sheetName = input,
						onChanged: (input) => sheetName = input,
					),
					RaisedButton(
						child: Text("Format Sheets"),
						onPressed: () {
							_createSheetsForEvent('nvk-test-event-2');
						},
					),
					RaisedButton(
						child: Text("Push to Sheet"),
						onPressed: () {
							_appendAll();
						},
					),
					RaisedButton(
						child: Text('Test'),
						onPressed: () {
							// _testSheetsApi();
						}
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
