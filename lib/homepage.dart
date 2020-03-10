import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scoutmobile2020/service/bluealliance.dart';
import 'package:scoutmobile2020/scan.dart';
import 'package:scoutmobile2020/service/qr.dart';
import 'package:scoutmobile2020/types/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scoutmode.dart';

final Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class Homepage extends StatefulWidget {
	@override
	_HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
	Schedule schedule;
	String eventcode = '';

	@override
	void initState () {
		super.initState();
		_reloadSchedule();
	}

	void _reloadSchedule () {
		_sharedPreferences.then((sp) {
			String scheduleStr = sp.getString('schedule');
			if (scheduleStr.isNotEmpty) {
				print('process schedule');
				try { setState(() { schedule = Schedule.fromJson(jsonDecode(scheduleStr)); }); }
				catch (error) { print(error); }
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
				appBar: new AppBar(
						title: new Text("FRC 1640 Scouting App"),
						backgroundColor: Colors.blue[900]),
				body: Builder(builder: (scaffoldContext) =>
				new Container(
					child: new Center(
						child: new Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								RaisedButton(
									child: Text('Scout Mode'),
									color: Colors.yellow,
									onPressed: () { Navigator.push( context, new MaterialPageRoute(builder: (context) => ScoutMode())); }
								),
								RaisedButton(
									child: Text('Scan Mode'),
									color: Colors.yellow,
									onPressed: () { Navigator.push(context, new MaterialPageRoute( builder: (context) => ScanMode())); }
								),
								Container(height: 40),
								RaisedButton(
									child: Text('Import Schedule from TBA'),
									color: Colors.yellow,
									onPressed: () async {
										await Bluealliance.promptForSchedule(scaffoldContext);
										_reloadSchedule();
									}
                ),
								RaisedButton(
									child: Text('Import Schedule from QR'),
									color: Colors.yellow,
									onPressed: () async {
										String scheduleStr = await QrTools.readCompressedQrCode();
										try {setState(() { schedule = Schedule.fromJson(jsonDecode(scheduleStr)); }); }
										catch (error) { print(error); }

										if (schedule != null) {
											(await _sharedPreferences).setString('schedule', jsonEncode(schedule.toJson()));
										}

										Scaffold.of(scaffoldContext).showSnackBar(SnackBar(content: Text(schedule != null ? 'Loaded Schedule' : 'Failed to parse schedule'), duration: Duration(seconds: 3)));
									}
                ),
								RaisedButton(
									child: Text(schedule == null ? 'Create Schedule QR' : 'Create Schedule QR (${schedule.eventName})'),
									color: Colors.yellow,
									onPressed: (schedule == null) ? null : () async {
										QrTools.buildCompressedQrCode(context, jsonEncode(schedule.toJson()));
									}
                )
							],
						),
					),
				)));
	}
}