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
	final int nextMatch;
	final String initials;
	final int position;
	final MatchData matchData = new MatchData();

	@override
	_ScoutModeState createState() => _ScoutModeState();

	ScoutMode({this.nextMatch, this.initials, this.position}) {
		if (this.nextMatch != null) {
			matchData.matchNumber = this.nextMatch.toString();
		}
		if (this.initials != null) {
			matchData.initials = this.initials;
		}
		if (this.position != null) {
			matchData.position = this.position;
		}
	}
}

class _ScoutModeState extends State<ScoutMode> {
	Stopwatch _stopwatch = new Stopwatch();
	double showntime;
	bool state = true;

	final formKey = GlobalKey<FormState>();
	List<int> teleopshotsx = <int>[];
	List<int> teleopshotsy = <int>[];
	List<int> autoshotsx = <int>[];
	List<int> autoshotsy = <int>[];
	List<int> autoshotsmade = <int>[];
	List<int> teleopshotsmade = <int>[];
	List<int> autoshotstype = <int>[];
	List<int> teleopshotstype = <int>[];

	String _clockText = "00:00";
	Timer _clockUpdateTimer;
	Duration _clockUpdateRate = Duration(milliseconds: 100);

	void _startClock () {
		_stopwatch.start();
		if (_clockUpdateTimer == null) {
			_clockUpdateTimer = Timer.periodic(_clockUpdateRate, (Timer timer) => setState(() {
				Duration elapsedTime = _stopwatch.elapsed;
				int seconds = elapsedTime.inSeconds;
				int millis	= elapsedTime.inMilliseconds - 1000 * seconds;
				_clockText = sprintf("%02d:%02d", [seconds, (millis/10).round()]);
			}));
		}
	}

	void _stopClock () {
		if (_clockUpdateTimer != null) {
			_stopwatch.stop();
			_clockUpdateTimer.cancel();
			_clockUpdateTimer = null;
			widget.matchData.climbtime = _stopwatch.elapsedMilliseconds / 1000;
		}
	}

	void _resetClock () {
		if (_clockUpdateTimer != null) {
			_clockUpdateTimer.cancel();
			_clockUpdateTimer = null;
		}
		_stopwatch.stop();
		_stopwatch.reset();
		widget.matchData.climbtime = 0;
		setState(() { _clockText = "00:00"; });
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
													initialValue: widget.matchData.initials,
													decoration: const InputDecoration(labelText: 'Enter your initials'),
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) { setState(() { widget.matchData.initials = input; }); },
													onFieldSubmitted: (input) { setState(() { widget.matchData.initials = input; }); },
													onChanged: (input) { setState(() { widget.matchData.initials = input; }); },
												),
												TextFormField(
													initialValue: widget.matchData.matchNumber,
													decoration: const InputDecoration(labelText: 'Enter the match number'),
													keyboardType: TextInputType.number,
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) { setState(() { widget.matchData.matchNumber = input; }); },
													onChanged: (input) { setState(() { widget.matchData.matchNumber = input; }); },
													onFieldSubmitted: (input) { setState(() { widget.matchData.matchNumber = input; }); }
												),
												TextFormField(
													initialValue: widget.matchData.teamNumber,
													decoration: const InputDecoration(labelText: "Enter Team Number"),
													keyboardType: TextInputType.number,
													validator: (input) => input.isEmpty ? 'Not a valid input' : null,
													onSaved: (input) { setState(() { widget.matchData.teamNumber = input; }); },
													onChanged: (input) { setState(() { widget.matchData.teamNumber = input; }); },
													onFieldSubmitted: (input) { setState(() { widget.matchData.teamNumber = input; }); },
												),
												Text('Select robot position'),
												Column(children: <Widget>[
													Row(children: <Widget>[
														RaisedButton(
															child: Text('Red 1'),
															color: (widget.matchData.position == 4) ? Colors.redAccent : Colors.grey,
															onPressed: () {
																widget.matchData.position = (widget.matchData.position == 4) ? -1 : 4;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Red 2'),
															color: (widget.matchData.position == 5) ? Colors.redAccent : Colors.grey,
															onPressed: () {
																widget.matchData.position = (widget.matchData.position == 5) ? -1 : 5;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Red 3'),
															color: (widget.matchData.position == 6) ? Colors.redAccent : Colors.grey,
															onPressed: () {
																widget.matchData.position = (widget.matchData.position == 6) ? -1 : 6;
																setState(() {});
															}
														)
													],
													mainAxisAlignment: MainAxisAlignment.center),
													Row(children: <Widget>[
														RaisedButton(
															child: Text('Blue 1'),
															color: (widget.matchData.position == 1) ? Colors.blueAccent : Colors.grey,
															onPressed: () {
																widget.matchData.position = (widget.matchData.position == 1) ? -1 : 1;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Blue 2'),
															color: (widget.matchData.position == 2) ? Colors.blueAccent : Colors.grey,
															onPressed: () {
																widget.matchData.position = (widget.matchData.position == 2) ? -1 : 2;
																setState(() {});
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('Blue 3'),
															color: (widget.matchData.position == 3) ? Colors.blueAccent : Colors.grey,
															onPressed: () {
																widget.matchData.position = (widget.matchData.position == 3) ? -1 : 3;
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
															color: widget.matchData.preloadedfuelcells == 0 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { widget.matchData.preloadedfuelcells = 0; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('1'),
															color: widget.matchData.preloadedfuelcells == 1 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { widget.matchData.preloadedfuelcells = 1; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('2'),
															color: widget.matchData.preloadedfuelcells == 2 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { widget.matchData.preloadedfuelcells = 2; });
															}
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text('3'),
															color: widget.matchData.preloadedfuelcells == 3 ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																setState(() { widget.matchData.preloadedfuelcells = 3; });
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
																Navigator.push(context, new MaterialPageRoute(builder: (context) => AutonPath(matchData: widget.matchData, onTap: () => _startClock())));
															},
														),
														VerticalDivider(width: 5.0),
														RaisedButton(
															child: Text("Teleop"),
															onPressed: () {
																Navigator.push(context, new MaterialPageRoute(builder: (context) => Teleop(matchData: widget.matchData, onTap: () => _startClock())));
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
														color: widget.matchData.park == 3 ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															setState(() { widget.matchData.park = 3; });
														}
													),
													VerticalDivider(width: 5.0),
													RaisedButton(
														child: Text('Park'),
														color: widget.matchData.park == 1 ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															setState(() { widget.matchData.park = 1; });
														}
													),
													VerticalDivider(width: 5.0),
													RaisedButton(
														child: Text('Climb'),
														color: widget.matchData.park == 2 ? Colors.greenAccent : Colors.grey,
														onPressed: () {
															setState(() { widget.matchData.park = 2; });
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
															child: Text(widget.matchData.levelability ? 'Yes' : 'No'),
															color: widget.matchData.levelability ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																widget.matchData.levelability = !widget.matchData.levelability;
																setState(() {});
															}
														)
													]),
													VerticalDivider(width: 5.0),
													Column(children: <Widget>[
														Text('Assisted?'),
														RaisedButton(
															child: Text(widget.matchData.assist ? 'Yes' : 'No'),
															color: widget.matchData.assist ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																widget.matchData.assist = !widget.matchData.assist;
																if (!widget.matchData.assist) { widget.matchData.typeassist = false; }
																setState(() {});
															}
														)
													]),
													VerticalDivider(width: 5.0),
													widget.matchData.assist ?
														Column(children: <Widget>[
															Text('Assist type'),
															RaisedButton(
																child: Text(widget.matchData.typeassist ? 'Active' : 'Passive'),
																color: widget.matchData.typeassist ? Colors.greenAccent : Colors.grey,
																onPressed: () {
																	widget.matchData.typeassist = !widget.matchData.typeassist;
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
																setState(() { widget.matchData.generalSuccess = v; });
															},
															starCount: 5,
															rating: widget.matchData.generalSuccess,
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
																setState(() { widget.matchData.defensiveSuccess = v; });
															},
															starCount: 5,
															rating: widget.matchData.defensiveSuccess,
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
																setState(() { widget.matchData.accuracy = v; });
															},
															starCount: 5,
															rating: widget.matchData.accuracy,
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
															child: Text(widget.matchData.floorpickup ? 'Yes' : 'No'),
															color: widget.matchData.floorpickup ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																widget.matchData.floorpickup = !widget.matchData.floorpickup;
																setState(() {});
															}
														)
													]),
													VerticalDivider(width: 10.0),
													Column(children: <Widget>[
														Text('Egregious	Fouls?'),
														RaisedButton(
															child: Text(widget.matchData.fouls ? 'Yes' : 'No'),
															color: widget.matchData.fouls ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																widget.matchData.fouls = !widget.matchData.fouls;
																setState(() {});
															}
														)
													]),
													VerticalDivider(width: 10.0),
													Column(children: <Widget>[
														Text('Had Problems?'),
														RaisedButton(
															child: Text(widget.matchData.problems ? 'Yes' : 'No'),
															color: widget.matchData.problems ? Colors.greenAccent : Colors.grey,
															onPressed: () {
																widget.matchData.problems = !widget.matchData.problems;
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
															child: Text("Clear and Increment Match"),
															onPressed:() async {
																bool shouldClear = await _confirmationPrompt(context, 'Are you sure you want to clear?');
																if (shouldClear) {
																	print('Clearing');
																	int nextMatch = int.tryParse(widget.matchData.matchNumber);
																	if (nextMatch != null) { nextMatch = nextMatch + 1; }
																	Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => ScoutMode(nextMatch:  nextMatch, initials: widget.matchData.initials, position: widget.matchData.position)));
																} else {
																	print('Not clearing...');
																}
															}
														)),
											],
											scrollDirection: Axis.vertical,
										)))),
			)
		);
	}

	void _submit() {
		int teamNumber = widget.matchData.teamNumber == '' ? 0 : int.parse(widget.matchData.teamNumber);
		int matchNumber = widget.matchData.matchNumber == '' ? 0 : int.parse(widget.matchData.matchNumber);

		_generateId(teamNumber, matchNumber);
		_extractshootingshootingpoints();
		_condensePoints();

		double generalSuccess = (widget.matchData.generalSuccess * 2).roundToDouble() / 2;
		if (generalSuccess <= 1e-10) { generalSuccess = null; }
		double defensiveSuccess = (widget.matchData.defensiveSuccess * 2).roundToDouble() / 2;
		if (defensiveSuccess <= 1e-10) { defensiveSuccess = null; }
		double accuracy = (widget.matchData.accuracy * 2).roundToDouble() / 2;
		if (accuracy <= 1e-10) { accuracy = null; }

		if (formKey.currentState.validate()) {
			formKey.currentState.save();
			var payload = {
				'initials': widget.matchData.initials,
				'id': widget.matchData.id,
				'teamnumber': teamNumber,
				'matchnumber': matchNumber,
				'position': widget.matchData.position,
				'preloadedfuelcells': widget.matchData.preloadedfuelcells,
				'autopathx': widget.matchData.autopathx,
				'autopathy': widget.matchData.autopathy,
				'autoshotsx': autoshotsx,
				'autoshotsy': autoshotsy,
				'autoshotsmade': autoshotsmade,
				'autoshotstype': autoshotstype,
				'teleopshotsx': teleopshotsx,
				'teleopshotsy': teleopshotsy,
				'teleopshotsmade': teleopshotsmade,
				'teleopshotstype': teleopshotstype,
				'climbtime': widget.matchData.climbtime,
				'park': widget.matchData.park,
				'positioncontrol': widget.matchData.spins.positionControl,
				'colorcontrol': widget.matchData.spins.colorControl,
				'generalsuccess': generalSuccess,
				'defensivesuccess': defensiveSuccess,
				'accuracy': accuracy,
				'floorpickup': widget.matchData.floorpickup ? 1 : 0,
				'fouls': widget.matchData.fouls ? 1 : 0,
				'problems': widget.matchData.problems ? 1 : 0
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
		List<Offset> points = widget.matchData.autopathpoints;
		widget.matchData.autopathx = [];
		widget.matchData.autopathy = [];
		for (int i = 0; i < points.length; i += 5) {
			widget.matchData.autopathx.add(((points[i].dx/MediaQuery.of(context).size.width)*686).round());
			widget.matchData.autopathy.add(((points[i].dy/MediaQuery.of(context).size.height)*1316).round());
		}
		print(widget.matchData.autopathx);
		print(widget.matchData.autopathy);
	}

	int _getTeam() {
		String scheduledTeam;
		String alphaPos;
		int betaPos;
		if (widget.matchData.position <= 3) {
			alphaPos = "blue";
		} else {
			alphaPos = "red";
		}
		betaPos = widget.matchData.position % 3;
		scheduledTeam = newGlobals.schedule[int.parse(widget.matchData.matchNumber)]["alliances"]
				[alphaPos]["team_keys"][betaPos];
		scheduledTeam = scheduledTeam.substring(3);
		return int.parse(scheduledTeam);
	}

	_generateId(int teamNumber, int matchNumber) {
		int id = teamNumber * 10000 + matchNumber;
		widget.matchData.id = id;
	}

	_extractshootingshootingpoints() {
		for(int i=0; i < widget.matchData.autoshots.length; i++) {
			autoshotsx.add(((widget.matchData.autoshots[i].pos.dx/MediaQuery.of(context).size.width)*686).round());
			autoshotsy.add(((widget.matchData.autoshots[i].pos.dy/MediaQuery.of(context).size.height)*1316).round());
			autoshotsmade.add(widget.matchData.autoshots[i].shotsMade);
			autoshotstype.add(widget.matchData.autoshots[i].shotType ? 1 : 0);
		}
		for(int i=0; i < widget.matchData.teleopshots.length; i++) {
			teleopshotsx.add(((widget.matchData.teleopshots[i].pos.dx/MediaQuery.of(context).size.width)*686).round());
			teleopshotsy.add(((widget.matchData.teleopshots[i].pos.dy/MediaQuery.of(context).size.height)*1316).round());
			teleopshotsmade.add(widget.matchData.teleopshots[i].shotsMade);
			teleopshotstype.add(widget.matchData.teleopshots[i].shotType ? 1 : 0);
		}
		
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
