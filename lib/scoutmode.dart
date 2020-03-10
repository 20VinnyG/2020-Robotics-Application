import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoutmobile2020/autonpath.dart';
import 'package:scoutmobile2020/service/qr.dart';
import 'package:scoutmobile2020/teleop.dart';
import 'package:scoutmobile2020/types/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:scoutmobile2020/types/match.dart';

final Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class ScoutMode extends StatefulWidget {
	final MatchData lastMatchData;

	@override
	_ScoutModeState createState() => _ScoutModeState();

	ScoutMode({this.lastMatchData});
}

class _ScoutModeState extends State<ScoutMode> {
	final _teamnumbercontroller = TextEditingController();
	final formKey = GlobalKey<FormState>();
	Schedule schedule;

	String climbPartnercount = 'Climbed with 0';
	Color climbColor = Colors.grey;
	int climbCount = 0;

	MatchData matchData;

	@override
	void initState () {
		super.initState();

		_sharedPreferences.then((sp) {
			String scheduleStr = sp.getString('schedule');
			print('schedule in scout init: ' + scheduleStr);
			if (scheduleStr.isNotEmpty) {
				print('process schedule');
				try { setState(() { schedule = Schedule.fromJson(jsonDecode(scheduleStr)); }); }
				catch (error) { print(error); }
			}
		});

		matchData = new MatchData();

		if (widget.lastMatchData != null) {
			matchData.initials = widget.lastMatchData.initials;
			matchData.position = widget.lastMatchData.position;

			int lastMatchN = int.tryParse(widget.lastMatchData.matchNumber);
			matchData.matchNumber = (lastMatchN != null) ? (lastMatchN + 1).toString() : '';
		}
	}

	@override
	Widget build(BuildContext context) {
		_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);

		return new WillPopScope(
			onWillPop: () async {
				return _confirmationPrompt(context, "Erase all data and go back to home screen?");
			},
			child: GestureDetector(
				onTap: () {
					FocusScopeNode currentFocus = FocusScope.of(context);
					if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
				},
				child: new Scaffold(
					appBar: new AppBar(
							title: new Text("Scout Mode"), backgroundColor: Colors.blue[900]),
					body: new Container(
							padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
							child: Builder(
									builder: (context) => Form(
											key: formKey,
											child: ListView(
												children: [
													Text(
														schedule != null ? "Loaded schedule for: ${schedule.eventName}" : 'No schedule loaded',
														style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
														textAlign: TextAlign.center,
													),
													Container(height: 10),
													Text("Prematch"),
													TextFormField(
														initialValue: matchData.initials,
														decoration: const InputDecoration(labelText: 'Enter your initials'),
														validator: (input) => input.isEmpty ? 'Not a valid input' : null,
														onSaved: (input) { setState(() { matchData.initials = input; }); },
														onFieldSubmitted: (input) { setState(() { matchData.initials = input; }); },
														onChanged: (input) { setState(() { matchData.initials = input; }); },
													),
													TextFormField(
														initialValue: matchData.matchNumber,
														decoration: const InputDecoration(labelText: 'Enter the match number'),
														keyboardType: TextInputType.number,
														validator: (input) => input.isEmpty ? 'Not a valid input' : null,
														onSaved: (input) { setState(() { matchData.matchNumber = input; });  _getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position); },
														onChanged: (input) { setState(() { matchData.matchNumber = input; });  _getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position); },
														onFieldSubmitted: (input) { setState(() { matchData.matchNumber = input; });  _getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position); }
													),
													Container(
														padding: const EdgeInsets.symmetric(
																	vertical: 16.0, horizontal: 16.0),
														child: Text('Select robot position'),
													),
													Column(children: <Widget>[
														Row(children: <Widget>[
															RaisedButton(
																child: Text('Red 1'),
																color: (matchData.position == 3) ? Colors.redAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.position = (matchData.position == 3) ? -1 : 3; });
																	_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Red 2'),
																color: (matchData.position == 4) ? Colors.redAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.position = (matchData.position == 4) ? -1 : 4; });
																	_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Red 3'),
																color: (matchData.position == 5) ? Colors.redAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.position = (matchData.position == 5) ? -1 : 5; });
																	_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);
																}
															)
														],
														mainAxisAlignment: MainAxisAlignment.center),
														Row(children: <Widget>[
															RaisedButton(
																child: Text('Blue 1'),
																color: (matchData.position == 0) ? Colors.blueAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.position = (matchData.position == 0) ? -1 : 0; });
																	_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Blue 2'),
																color: (matchData.position == 1) ? Colors.blueAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.position = (matchData.position == 1) ? -1 : 1; });
																	_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Blue 3'),
																color: (matchData.position == 2) ? Colors.blueAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.position = (matchData.position == 2) ? -1 : 2; });
																	_getTeam(int.tryParse(matchData.matchNumber) ?? -1, matchData.position);
																}
															)
														],
														mainAxisAlignment: MainAxisAlignment.center)
													],
													mainAxisAlignment: MainAxisAlignment.center),
													TextField(
														controller: _teamnumbercontroller,
														decoration: const InputDecoration(labelText: "Enter Team Number"),
														onChanged: (input) {
															setState(() {
																matchData.teamNumber = input;
															});
													}),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Container(
														padding: const EdgeInsets.symmetric(
																	vertical: 16.0, horizontal: 16.0),
														child: Text('Preloaded Number of Fuel Cells'),
													),
													Column(children: <Widget>[
														Row(children: <Widget>[
															RaisedButton(
																child: Text('0'),
																color: matchData.preloadedfuelcells == 0 ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.preloadedfuelcells = 0; });
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('1'),
																color: matchData.preloadedfuelcells == 1 ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.preloadedfuelcells = 1; });
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('2'),
																color: matchData.preloadedfuelcells == 2 ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.preloadedfuelcells = 2; });
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('3'),
																color: matchData.preloadedfuelcells == 3 ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	setState(() { matchData.preloadedfuelcells = 3; });
																}
															)
														],
														mainAxisAlignment: MainAxisAlignment.center
														)
													]),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Text("Path and Shots"),
													Row(
														children: <Widget>[
															RaisedButton(
																child: Text("Auton"),
																onPressed: () {
																	Navigator.push(context, new MaterialPageRoute(builder: (context) => AutonPath(matchData: matchData)));
																},
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text("Teleop"),
																onPressed: () {
																	Navigator.push(context, new MaterialPageRoute(builder: (context) => Teleop(matchData: matchData)));
																},
															)
														],
														mainAxisAlignment: MainAxisAlignment.center
													),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Text("Endgame"),
													Row(children: <Widget>[
														RaisedButton(
															child: Text('Neither'),
															color: matchData.park == 3 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { matchData.park = 3; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Park'),
															color: matchData.park == 1 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { matchData.park = 1; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Climb'),
															color: matchData.park == 2 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { matchData.park = 2; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text(climbPartnercount),
															color: climbColor,
															onPressed: () {
																climbCount = (climbCount + 1) % 3;
																setState(() {
																	if(climbCount == 0) {
																		climbColor = Colors.grey;
																		matchData.numberClimbedWith = 0;
																	} else if(climbCount == 1) {
																		climbColor = Colors.blue;
																		matchData.numberClimbedWith = 1;
																	} else  {
																		climbColor = Colors.yellow;
																		matchData.numberClimbedWith = 2;
																	}
																	climbPartnercount = 'Climbed with ' + matchData.numberClimbedWith.toString();
																});
															},
														),
													],
													mainAxisAlignment: MainAxisAlignment.center
													),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Container(
														padding: const EdgeInsets.symmetric(
																	vertical: 16.0, horizontal: 16.0),
														child: Row(children: <Widget>[
														Column(children: <Widget>[
															Text('Leveling ability?'),
															RaisedButton(
																child: Text(matchData.levelability ? 'Yes' : 'No'),
																color: matchData.levelability ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	matchData.levelability = !matchData.levelability;
																	setState(() {});
																}
															)
														]),
														VerticalDivider(width: 5.0),
														Column(children: <Widget>[
															Text('Assisted?'),
															RaisedButton(
																child: Text(matchData.assist ? 'Yes' : 'No'),
																color: matchData.assist ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	matchData.assist = !matchData.assist;
																	if (!matchData.assist) { matchData.typeassist = false; }
																	setState(() {});
																}
															)
														]),
														VerticalDivider(width: 5.0),
														matchData.assist ?
															Column(children: <Widget>[
																Text('Assist type'),
																RaisedButton(
																	child: Text(matchData.typeassist ? 'Active' : 'Passive'),
																	color: matchData.typeassist ? Colors.greenAccent : Colors.grey,
																	onPressed: () {
																		matchData.typeassist = !matchData.typeassist;
																		setState(() {});
																	}
																)
															]) : Container(),
													]),
													),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Text("Post-Match"),
													Column(children: <Widget>[
														Text("General Success"),
														SmoothStarRating(
																allowHalfRating: true,
																onRatingChanged: (v) {
																	setState(() { matchData.generalSuccess = v; });
																},
																starCount: 5,
																rating: matchData.generalSuccess,
																size: 40.0,
																filledIconData: Icons.star,
																halfFilledIconData: Icons.star_half,
																color: Colors.blue,
																borderColor: Colors.blue,
																spacing: 0.0),
														Text("Defensive Success"),
														SmoothStarRating(
																allowHalfRating: true,
																onRatingChanged: (v) {
																	setState(() { matchData.defensiveSuccess = v; });
																},
																starCount: 5,
																rating: matchData.defensiveSuccess,
																size: 40.0,
																filledIconData: Icons.star,
																halfFilledIconData: Icons.star_half,
																color: Colors.blue,
																borderColor: Colors.blue,
																spacing: 0.0),
														Text("Accuracy Rating"),
														SmoothStarRating(
																allowHalfRating: true,
																onRatingChanged: (v) {
																	setState(() { matchData.accuracy = v; });
																},
																starCount: 5,
																rating: matchData.accuracy,
																size: 40.0,
																filledIconData: Icons.star,
																halfFilledIconData: Icons.star_half,
																color: Colors.blue,
																borderColor: Colors.blue,
																spacing: 0.0),
													],
													mainAxisAlignment: MainAxisAlignment.center,),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Row(children: <Widget>[
														Column(children: <Widget>[
															Text('Floor Pickup?'),
															RaisedButton(
																child: Text(matchData.floorpickup ? 'Yes' : 'No'),
																color: matchData.floorpickup ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	matchData.floorpickup = !matchData.floorpickup;
																	setState(() {});
																}
															)
														]),
														VerticalDivider(width: 10.0),
														Column(children: <Widget>[
															Text('Egregious	Fouls?'),
															RaisedButton(
																child: Text(matchData.fouls ? 'Yes' : 'No'),
																color: matchData.fouls ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	matchData.fouls = !matchData.fouls;
																	setState(() {});
																}
															)
														]),
														VerticalDivider(width: 10.0),
														Column(children: <Widget>[
															Text('Had Problems?'),
															RaisedButton(
																child: Text(matchData.problems ? 'Yes' : 'No'),
																color: matchData.problems ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	matchData.problems = !matchData.problems;
																	setState(() {});
																}
															)
															])
													],
													mainAxisAlignment: MainAxisAlignment.center),
													Divider(
														height: 30.0,
														indent: 5.0,
														color: Colors.black,
													),
													Container(
															padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
															child: RaisedButton(
																child: Text("Generate QR"),
																onPressed:() {
																	_submit();
																},
															)),
													Container(
															padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
															child: RaisedButton(
																child: Text("Clear and Increment Match"),
																onPressed:() async {
																	bool shouldClear = await _confirmationPrompt(context, 'Are you sure you want to clear?');
																	if (shouldClear) {
																		Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => ScoutMode(lastMatchData: matchData)));
																	}
																}
													)),
													Container(
															padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
															child: RaisedButton(
																child: Text("Recover last match"),
																onPressed:() async {
																	if (widget.lastMatchData == null) {
																		Scaffold.of(context).showSnackBar(SnackBar(content: Text('No match data to reset'), duration: Duration(seconds: 3)));
																		return;
																	}
																	String lastMatchInfo = widget.lastMatchData.matchNumber + ' (' + widget.lastMatchData.teamNumber + ')';
																	bool shouldClear = await _confirmationPrompt(context, 'Are you sure you want to recover match $lastMatchInfo and throw away this one?');
																	if (shouldClear) {
																		setState(() { matchData = widget.lastMatchData; });
																		Scaffold.of(context).showSnackBar(SnackBar(content: Text('Reset match: $lastMatchInfo.'), duration: Duration(seconds: 3)));
																	}
																}
													)),
												],
												scrollDirection: Axis.vertical,
											)))),
				)
			));
	}

	void _submit() {
		int teamNumber = matchData.teamNumber == '' ? 0 : int.parse(matchData.teamNumber);
		int matchNumber = matchData.matchNumber == '' ? 0 : int.parse(matchData.matchNumber);

		_generateId(teamNumber, matchNumber);

		if (formKey.currentState.validate()) {
			formKey.currentState.save();

			var payload = matchData.toJson();
			QrTools.buildCompressedQrCode(context, jsonEncode(payload));
		}
	}

	void _getTeam (int matchNumber, int position) {
		if (schedule == null) { return; }

		setState(() {
			int teamNumber = schedule[matchNumber][position];
			if (teamNumber <= 0) {
				_teamnumbercontroller.text = '';
				matchData.teamNumber = '';
			} else {
				_teamnumbercontroller.text = teamNumber.toString();
				matchData.teamNumber = teamNumber.toString();
			}
		});
	}

	void _generateId(int teamNumber, int matchNumber) {
		int id = teamNumber * 10000 + matchNumber;
		matchData.id = id;
	}

	Future<bool> _confirmationPrompt (BuildContext context, String prompt) async {
		bool confirmation = false;
		await showDialog(
				context: context,
				builder: (context) {
					return AlertDialog(
						title: Text(prompt),
						content: Column(
							children: <Widget>[
								Row(
									children: <Widget>[
										RaisedButton(
											child: Text('Yes'),
											onPressed: () { confirmation = true; Navigator.pop(context); }
										),
										Container(width: 5.0),
										RaisedButton(
											child: Text('No'),
											onPressed: () { confirmation = false; Navigator.pop(context); }
										)
									],
									mainAxisAlignment: MainAxisAlignment.center,
									mainAxisSize: MainAxisSize.min,
								)
							],
							mainAxisAlignment: MainAxisAlignment.center,
							mainAxisSize: MainAxisSize.min
						));
			});
			return confirmation;
	}
}
