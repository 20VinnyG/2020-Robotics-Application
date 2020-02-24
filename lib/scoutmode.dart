import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoutmobile2020/autonpath.dart';
import 'package:scoutmobile2020/bluealliance.dart';
import 'package:scoutmobile2020/teleop.dart';
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
				_clockText = sprintf("%02d:%03d", [seconds, millis]);
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
		return GestureDetector(
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
													initialValue: newMatch.initials,
													decoration: const InputDecoration(labelText: 'Enter your initials'),
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) { setState(() { newMatch.initials = input; }); },
													onFieldSubmitted: (input) { setState(() { newMatch.initials = input; }); },
													onChanged: (input) { setState(() { newMatch.initials = input; }); },
												),
												TextFormField(
													initialValue: newMatch.matchNumber,
													decoration: const InputDecoration(labelText: 'Enter the match number'),
													keyboardType: TextInputType.number,
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) { setState(() { newMatch.matchNumber = input; }); },
													onChanged: (input) { setState(() { newMatch.matchNumber = input; }); },
													onFieldSubmitted: (input) { setState(() { newMatch.matchNumber = input; }); }
												),
												TextFormField(
													initialValue: newMatch.teamNumber,
													decoration: const InputDecoration(labelText: "Enter Team Number"),
													keyboardType: TextInputType.number,
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) { setState(() { newMatch.teamNumber = input; }); },
													onChanged: (input) { setState(() { newMatch.teamNumber = input; }); },
													onFieldSubmitted: (input) { setState(() { newMatch.teamNumber = input; }); },
												),
												Text('Select robot position'),
												Column(children: <Widget>[
													Row(children: <Widget>[
														RaisedButton(
															child: Text('Red 1'),
															color: (newMatch.position == 4) ? Colors.redAccent : Colors.grey,
															onPressed: () {
																newMatch.position = (newMatch.position == 4) ? -1 : 4;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Red 2'),
															color: (newMatch.position == 5) ? Colors.redAccent : Colors.grey,
															onPressed: () {
																newMatch.position = (newMatch.position == 5) ? -1 : 5;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Red 3'),
															color: (newMatch.position == 6) ? Colors.redAccent : Colors.grey,
															onPressed: () {
																newMatch.position = (newMatch.position == 6) ? -1 : 6;
																setState(() {});
															}
														)
													],
													mainAxisAlignment: MainAxisAlignment.center),
													Row(children: <Widget>[
														RaisedButton(
															child: Text('Blue 1'),
															color: (newMatch.position == 1) ? Colors.blueAccent : Colors.grey,
															onPressed: () {
																newMatch.position = (newMatch.position == 1) ? -1 : 1;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Blue 2'),
															color: (newMatch.position == 2) ? Colors.blueAccent : Colors.grey,
															onPressed: () {
																newMatch.position = (newMatch.position == 2) ? -1 : 2;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Blue 3'),
															color: (newMatch.position == 3) ? Colors.blueAccent : Colors.grey,
															onPressed: () {
																newMatch.position = (newMatch.position == 3) ? -1 : 3;
																setState(() {});
															}
														)
													],
													mainAxisAlignment: MainAxisAlignment.center)
												],
												mainAxisAlignment: MainAxisAlignment.center),
												Divider(
													height: 30.0,
													indent: 5.0,
													color: Colors.black,
												),
												Text('Preloaded number of fuel cells'),
												Column(children: <Widget>[
													Row(children: <Widget>[
														RaisedButton(
															child: Text('0'),
															color: newMatch.preloadedfuelcells == 0 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { newMatch.preloadedfuelcells = 0; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('1'),
															color: newMatch.preloadedfuelcells == 1 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { newMatch.preloadedfuelcells = 1; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('2'),
															color: newMatch.preloadedfuelcells == 2 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { newMatch.preloadedfuelcells = 2; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('3'),
															color: newMatch.preloadedfuelcells == 3 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { newMatch.preloadedfuelcells = 3; });
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
																Navigator.push(context, new MaterialPageRoute(builder: (context) => AutonPath(matchData: newMatch)));
															},
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text("Teleop"),
															onPressed: () {
																Navigator.push(context, new MaterialPageRoute(builder: (context) => Teleop(matchData: newMatch, onTap: () => _startClock())));
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
																child: Text("Start Timer"),
																onPressed: () {
																	_startClock();
																},
															),
                              Container(width: 5.0),
															RaisedButton(
																child: Text("Stop Timer"),
																onPressed: () {
																	_stopClock();
                                  print(_stopwatch.elapsedMilliseconds);
																},
															),
															Container(width: 5.0),
															RaisedButton(
																child: Text("Reset Timer"),
																onPressed: () {
																	_resetClock();
																},
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
												Text('End game state'),
												Row(children: <Widget>[
													RaisedButton(
														child: Text('Neither'),
														color: newMatch.park == 3 ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															setState(() { newMatch.park = 3; });
														}
													),
													VerticalDivider(width: 5.0),
													RaisedButton(
														child: Text('Park'),
														color: newMatch.park == 1 ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															setState(() { newMatch.park = 1; });
														}
													),
													VerticalDivider(width: 5.0),
													RaisedButton(
														child: Text('Climb'),
														color: newMatch.park == 2 ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															setState(() { newMatch.park = 2; });
														}
													)
												],
												mainAxisAlignment: MainAxisAlignment.center
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
														Container(),
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
																setState(() { newMatch.generalSuccess = v; });
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
																setState(() { newMatch.defensiveSuccess = v; });
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
                                setState(() { newMatch.accuracy = v; });
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
			)
		);
	}

	void _submit() {
		int teamNumber = newMatch.teamNumber == '' ? 0 : int.parse(newMatch.teamNumber);
		int matchNumber = newMatch.matchNumber == '' ? 0 : int.parse(newMatch.matchNumber);

		_generateId(teamNumber, matchNumber);
		_extractshootingshootingpoints();
		_condensePoints();

		if (formKey.currentState.validate()) {
			formKey.currentState.save();
			var payload = {
				'initials': newMatch.initials,
				'id': newMatch.id,
				'teamnumber': int.parse(newMatch.teamNumber),
				'matchnumber': int.parse(newMatch.matchNumber),
				'position': newMatch.position,
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
				'climbtime': newMatch.climbtime,
				'park': newMatch.park,
				'positioncontrol': newMatch.spins.positionControl,
				'colorcontrol': newMatch.spins.colorControl,
				'generalsuccess': (newMatch.generalSuccess * 2).roundToDouble() / 2,
				'defensivesuccess': (newMatch.defensiveSuccess * 2).roundToDouble() / 2,
				'accuracy': (newMatch.accuracy * 2).roundToDouble() / 2,
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

	_condensePoints() {
		List<Offset> points = newMatch.autopathpoints;
		newMatch.autopathx = [];
		newMatch.autopathy = [];
		for (int i = 0; i < points.length; i += 5) {
			newMatch.autopathx.add(points[i].dx.round());
			newMatch.autopathy.add(points[i].dy.round());
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
		scheduledTeam = newGlobals.schedule[int.parse(newMatch.matchNumber)]["alliances"]
				[alphaPos]["team_keys"][betaPos];
		scheduledTeam = scheduledTeam.substring(3);
		return int.parse(scheduledTeam);
	}

	_generateId(int teamNumber, int matchNumber) {
		int id = teamNumber * 10000 + matchNumber;
		newMatch.id = id;
	}

	_extractshootingshootingpoints() {
		for(int i=0; i < newMatch.autoshots.length; i++) {
			autoshotsx.add(newMatch.autoshots[i].pos.dx.round());
			autoshotsy.add(newMatch.autoshots[i].pos.dy.round());
			autoshotsmade.add(newMatch.autoshots[i].shotsMade);
			autoshotstype.add(newMatch.autoshots[i].shotType ? 1 : 0);
		}
		for(int i=0; i < newMatch.teleopshots.length; i++) {
			teleopshotsx.add(newMatch.teleopshots[i].pos.dx.round());
			teleopshotsy.add(newMatch.teleopshots[i].pos.dy.round());
			teleopshotsmade.add(newMatch.teleopshots[i].shotsMade);
			teleopshotstype.add(newMatch.teleopshots[i].shotType ? 1 : 0);
		}
		
	}
}
