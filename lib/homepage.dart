import 'package:flutter/material.dart';
import 'package:scoutmobile2020/service/bluealliance.dart';
import 'package:scoutmobile2020/scan.dart';
import 'package:scoutmobile2020/types/schedule.dart';
import 'scoutmode.dart';

class Homepage extends StatefulWidget {
	@override
	_HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
	Schedule schedule;
	String eventcode = '';

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
									onPressed: () { Navigator.push( context, new MaterialPageRoute(builder: (context) => ScoutMode(schedule: schedule))); }
								),
								RaisedButton(
									child: Text('Scan Mode'),
									color: Colors.yellow,
									onPressed: () { Navigator.push(context, new MaterialPageRoute( builder: (context) => ScanMode())); }
								),
								RaisedButton(
									child: Text('Import Match Schedule'),
									color: Colors.yellow,
									onPressed: () async {
											schedule = await Bluealliance.promptForSchedule(scaffoldContext) ?? schedule;
									}),
							],
						),
					),
				)));
	}
}