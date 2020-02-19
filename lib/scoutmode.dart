import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frc1640scoutingframework/autonpath.dart';
import 'package:frc1640scoutingframework/bluealliance.dart';
import 'package:frc1640scoutingframework/teleop.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:sprintf/sprintf.dart';
import 'match.dart';
import 'package:archive/archive.dart';

class ScoutMode extends StatefulWidget {
	@override
	_ScoutModeState createState() => _ScoutModeState();
}

class _ScoutModeState extends State<ScoutMode> {
	Stopwatch _stopwatch = new Stopwatch();
	double showntime;
	bool state = true;

	final formKey = GlobalKey<FormState>();
	MatchData newMatch = new MatchData();
	List<int> teleopshotsx = <int>[];
	List<int> teleopshotsy = <int>[];
	List<int> autoshotsx = <int>[];
	List<int> autoshotsy = <int>[];
	List<int> autoshotsmade = <int>[];
	List<int> teleopshotsmade = <int>[];
	List<int> autoshotstype = <int>[];
	List<int> teleopshotstype = <int>[];

	String _clockText = "00:000";
	Timer _clockUpdateTimer;
	Duration _clockUpdateRate = Duration(milliseconds: 100);

	void _startClock () {
		_stopwatch.start();
		if (_clockUpdateTimer == null) {
			_clockUpdateTimer = Timer.periodic(_clockUpdateRate, (Timer timer) => setState(() {
				Duration elapsedTime = _stopwatch.elapsed;
				int seconds = elapsedTime.inSeconds;
				int millis	= elapsedTime.inMilliseconds - 1000 * seconds;
				setState(() { _clockText = sprintf("%02d:%03d", [seconds, millis]); });
			}));
		}
	}

	void _stopClock () {
		if (_clockUpdateTimer != null) {
			_stopwatch.stop();
			_clockUpdateTimer.cancel();
			_clockUpdateTimer = null;
			newMatch.climbtime = _stopwatch.elapsedMilliseconds / 1000;
		}
	}

	void _resetClock () {
		if (_clockUpdateTimer != null) {
			_clockUpdateTimer.cancel();
			_clockUpdateTimer = null;
		}
		_stopwatch.stop();
		_stopwatch.reset();
		newMatch.climbtime = 0;
		setState(() { _clockText = "00:000"; });
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
					title: new Text("Scout Mode"), backgroundColor: Colors.blue[900]),
			body: new Container(
					padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
					child: Builder(
							builder: (context) => Form(
									key: formKey,
									child: ListView(
										children: [
											Container(
													padding: const EdgeInsets.symmetric(
														vertical: 16.0, horizontal: 16.0),
														child: RaisedButton(
															child: Text("Import Schedule"),
															onPressed: () {
																Navigator.push(context, new MaterialPageRoute(builder: (context) => Bluealliance()));
															},
													)),
											Divider(
												height: 30.0,
												indent: 5.0,
												color: Colors.black,
											),
											Text("Prematch"),
											TextFormField(
												decoration: const InputDecoration(hintText: 'Enter your initials'),
												validator: (input) => input.isEmpty ? 'Not a valid input' : null,
												onSaved: (input) => newMatch.initials = input,
												onFieldSubmitted: (input) => newMatch.initials = input,
												onChanged: (input) => newMatch.initials = input,
											),
											TextFormField(
													decoration: const InputDecoration(hintText: 'Enter the match number'),
													keyboardType: TextInputType.number,
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) => newMatch.matchNumber = int.parse(input),
													onChanged: (input) => newMatch.matchNumber = int.parse(input),
													onFieldSubmitted: (input) => newMatch.matchNumber = int.parse(input)),
											DropdownButton(
												items: [
													DropdownMenuItem(value: 1, child: Text("Blue1")),
													DropdownMenuItem(value: 2, child: Text("Blue2")),
													DropdownMenuItem(value: 3, child: Text("Blue3")),
													DropdownMenuItem(value: 4, child: Text("Red1")),
													DropdownMenuItem(value: 5, child: Text("Red2")),
													DropdownMenuItem(value: 6, child: Text("Red3")),
												],
												onChanged: (value) {
													setState(() {
														newMatch.position = value;
													});
												},
												hint: Text("Robot Position"),
												value: newMatch.position,
											),
											TextFormField(
												decoration: const InputDecoration(hintText: "Enter Team Number"),
												keyboardType: TextInputType.number,
												validator: (input) => input.isEmpty ? 'Not a valid input' : null,
												onSaved: (input) => newMatch.teamNumber = int.parse(input),
												onChanged: (input) => newMatch.teamNumber = int.parse(input),
												onFieldSubmitted: (input) => newMatch.teamNumber = int.parse(input),
											),
											/*Slider(
												value: newMatch.initiationlinepos,
												onChanged: (double delta) {
													setState(() => newMatch.initiationlinepos = delta);
												},
												min: 0.0,
												max: 10.0,
												divisions: 10,
											),*/
											Text("Preloaded Number of Fuel Cells?"),
											DropdownButton(
												items: [
													DropdownMenuItem(value: 0, child: Text("0")),
													DropdownMenuItem(value: 1, child: Text("1")),
													DropdownMenuItem(value: 2, child: Text("2")),
													DropdownMenuItem(value: 3, child: Text("3"))
												],
												onChanged: (value) {
													setState(() {
														newMatch.preloadedfuelcells = value;
													});
												},
												hint: Text("Number of Preloaded Fuel Cells"),
												value: newMatch.preloadedfuelcells,
											),
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
															Navigator.push(context, new MaterialPageRoute(builder: (context) => AutonPath(matchData: newMatch)));
														},
													),
													VerticalDivider(width: 5.0),
													RaisedButton(
														child: Text("Teleop"),
														onPressed: () {
															Navigator.push(context, new MaterialPageRoute(builder: (context) => Teleop(matchData: newMatch)));
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
											Column(children: <Widget>[
													Text('$_clockText', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 3.0)),
													Row(children: <Widget>[
														RaisedButton(
															child: Text("Stop Climb Timer"),
															onPressed: () {
																_stopClock();
															},
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text("Reset Climb Timer"),
															onPressed: () {
																_resetClock();
															},
														)
													],
													mainAxisAlignment: MainAxisAlignment.center
													)
											]),
											DropdownButton(
												items: [
													DropdownMenuItem(value: int.parse("1"), child: Text("Park")),
													DropdownMenuItem(value: int.parse("2"), child: Text("Climb")),
													DropdownMenuItem(value: int.parse("3"), child: Text("Neither")),
												],
												onChanged: (value) {
													setState(() {
														newMatch.park = value;
													});
												},
												hint: Text("End Game State?"),
												value: newMatch.park,
											),
											Divider(
												height: 30.0,
												indent: 5.0,
												color: Colors.black,
											),
											Row(children: <Widget>[
												Column(children: <Widget>[
													Text('Leveling ability?'),
													RaisedButton(
														child: Text(newMatch.levelability ? 'Yes' : 'No'),
														color: newMatch.levelability ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															newMatch.levelability = !newMatch.levelability;
															setState(() {});
														}
													)
												]),
												VerticalDivider(width: 5.0),
												Column(children: <Widget>[
													Text('Assisted?'),
													RaisedButton(
														child: Text(newMatch.assist ? 'Yes' : 'No'),
														color: newMatch.assist ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															newMatch.assist = !newMatch.assist;
															if (!newMatch.assist) { newMatch.typeassist = false; }
															setState(() {});
														}
													)
												]),
												VerticalDivider(width: 5.0),
												newMatch.assist ?
													Column(children: <Widget>[
														Text('Assist type'),
														RaisedButton(
															child: Text(newMatch.typeassist ? 'Active' : 'Passive'),
															color: newMatch.typeassist ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																newMatch.typeassist = !newMatch.typeassist;
																setState(() {});
															}
														)
													]) :
													Container()
											]),
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
															newMatch.generalSuccess = v;
															setState(() {});
														},
														starCount: 5,
														rating: newMatch.generalSuccess,
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
															newMatch.defensiveSuccess = v;
															setState(() {});
														},
														starCount: 5,
														rating: newMatch.defensiveSuccess,
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
															newMatch.accuracy = v;
															setState(() {});
														},
														starCount: 5,
														rating: newMatch.accuracy,
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
														child: Text(newMatch.floorpickup ? 'Yes' : 'No'),
														color: newMatch.floorpickup ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															newMatch.floorpickup = !newMatch.floorpickup;
															setState(() {});
														}
													)
												]),
												VerticalDivider(width: 10.0),
												Column(children: <Widget>[
													Text('Egregious	Fouls?'),
													RaisedButton(
														child: Text(newMatch.fouls ? 'Yes' : 'No'),
														color: newMatch.fouls ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															newMatch.fouls = !newMatch.fouls;
															setState(() {});
														}
													)
												]),
												VerticalDivider(width: 10.0),
												Column(children: <Widget>[
													Text('Had Problems?'),
													RaisedButton(
														child: Text(newMatch.problems ? 'Yes' : 'No'),
														color: newMatch.problems ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															newMatch.problems = !newMatch.problems;
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
													padding: const EdgeInsets.symmetric(
															vertical: 16.0, horizontal: 16.0),
													child: RaisedButton(
														child: Text("Generate QR"),
														onPressed:() {
															_submit();
														},
													)),
											Container(
													padding: const EdgeInsets.symmetric(
															vertical: 16.0, horizontal: 16.0),
													child: RaisedButton(
														child: Text("Clear"),
														onPressed:() {
															AutoPath().points = <Offset>[];
															Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => ScoutMode()));
														},
													)),
										],
										scrollDirection: Axis.vertical,
									)))),
			floatingActionButton: FloatingActionButton.extended(
				icon: Icon(Icons.timer),
				label: Text("Start Climb Timer"),
				onPressed: () {
					_startClock();
				},
			),
		);
	}

	void _submit() {
		_generateId();
		_extractshootingshootingpoints();
		if (formKey.currentState.validate()) {
			formKey.currentState.save();
			var payload = {
				'initials': newMatch.initials.toString(),
				'id': newMatch.id,
				'teamnumber': newMatch.teamNumber,
				'matchnumber': newMatch.matchNumber,
				'initiationposition': newMatch.initiationlinepos,
				'preloadedfuelcells': newMatch.preloadedfuelcells,
				'autopathx': newMatch.autopathx,
				'autopathy': newMatch.autopathy,
				'autoshotsx': autoshotsx,
				'autoshotsy': autoshotsy,
				'autoshotsmade': autoshotsmade,
				'autoshotstype': autoshotstype,
				'teleopshotsx': teleopshotsx,
				'teleopshotsy': teleopshotsy,
				'teleopshotsmade': teleopshotsmade,
				'teleopshotstype': teleopshotstype,
				'generalsuccess': newMatch.generalSuccess,
				'defensivesuccess': newMatch.defensiveSuccess,
				'accuracy': newMatch.accuracy,
				'floorpickup': newMatch.floorpickup ? 1 : 0,
				'fouls': newMatch.fouls ? 1 : 0,
				'problems': newMatch.problems ? 1 : 0
			};
			List<int> stringBytes = utf8.encode(json.encode(payload));
			List<int> gzipBytes = new GZipEncoder().encode(stringBytes);
			String compressedString = base64.encode(gzipBytes);
			showDialog (
					context: context,
					builder: (context) {
						return Dialog(
								child: QrImage(
							data: compressedString,
						));
					});
		}
	}

	int _getTeam() {
		String scheduledTeam;
		String alphaPos;
		int betaPos;
		if (newMatch.position <= 3) {
			alphaPos = "blue";
		} else {
			alphaPos = "red";
		}
		betaPos = newMatch.position % 3;
		scheduledTeam = newGlobals.schedule[newMatch.matchNumber]["alliances"]
				[alphaPos]["team_keys"][betaPos];
		scheduledTeam = scheduledTeam.substring(3);
		return int.parse(scheduledTeam);
	}

	_generateId() {
		int id = newMatch.teamNumber * 10000 + newMatch.matchNumber;
		newMatch.id = id;
	}

	_extractshootingshootingpoints() {
		for(int i=0; i < newMatch.autoshots.length; i++) {
			autoshotsx.add(newMatch.autoshots[i].pos.dx.round());
			autoshotsy.add(newMatch.autoshots[i].pos.dy.round());
			autoshotsmade.add(newMatch.autoshots[i].shotsMade);
			autoshotstype.add(newMatch.autoshots[i].shotType ? 1 : 0);
		}
		for(int i=0; i< newMatch.autoshots.length; i++) {
			teleopshotsx.add(newMatch.teleopshots[i].pos.dx.round());
			teleopshotsy.add(newMatch.teleopshots[i].pos.dy.round());
			teleopshotsmade.add(newMatch.teleopshots[i].shotsMade);
			teleopshotstype.add(newMatch.teleopshots[i].shotType ? 1 : 0);
		}
		
	}
}
