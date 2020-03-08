import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoutmobile2020/autonpath.dart';
import 'package:scoutmobile2020/service/bluealliance.dart';
import 'package:scoutmobile2020/teleop.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scoutmobile2020/types/schedule.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:scoutmobile2020/types/match.dart';
import 'package:archive/archive.dart';

class ScoutMode extends StatefulWidget {
	final Schedule schedule;
	final int nextMatch;
	final String initials;
	final int position;
	final MatchData matchData = new MatchData();
  final MatchData matchDataScan;

	@override
	_ScoutModeState createState() => _ScoutModeState();

	ScoutMode({this.nextMatch, this.initials, this.position, this.schedule, this.matchDataScan}) {
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
	final _teamnumbercontroller = TextEditingController();
	final formKey = GlobalKey<FormState>();
	Schedule schedule;

	String climbPartnercount = 'Climbed with 0';
	Color climbColor = Colors.grey;
	int climbCount = 0;

	@override
	void initState () {
		super.initState();
		schedule = widget.schedule;
	}

	@override
	Widget build(BuildContext context) {
		_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);

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
													Container(
															padding: const EdgeInsets.symmetric(
																vertical: 16.0, horizontal: 16.0),
																child: RaisedButton(
																	child: Text("Import Schedule"),
																	onPressed: () async {
																		schedule = await Bluealliance.promptForSchedule(context) ?? schedule;
																		_getTeam(int.tryParse(widget.matchData.matchNumber) ?? 0, widget.matchData.position);
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
														onSaved: (input) { setState(() { widget.matchData.matchNumber = input; });  _getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position); },
														onChanged: (input) { setState(() { widget.matchData.matchNumber = input; });  _getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position); },
														onFieldSubmitted: (input) { setState(() { widget.matchData.matchNumber = input; });  _getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position); }
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
																color: (widget.matchData.position == 3) ? Colors.redAccent : Colors.grey,
																onPressed: () {
																	setState(() { widget.matchData.position = (widget.matchData.position == 3) ? -1 : 3; });
																	_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Red 2'),
																color: (widget.matchData.position == 4) ? Colors.redAccent : Colors.grey,
																onPressed: () {
																	setState(() { widget.matchData.position = (widget.matchData.position == 4) ? -1 : 4; });
																	_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Red 3'),
																color: (widget.matchData.position == 5) ? Colors.redAccent : Colors.grey,
																onPressed: () {
																	setState(() { widget.matchData.position = (widget.matchData.position == 5) ? -1 : 5; });
																	_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);
																}
															)
														],
														mainAxisAlignment: MainAxisAlignment.center),
														Row(children: <Widget>[
															RaisedButton(
																child: Text('Blue 1'),
																color: (widget.matchData.position == 0) ? Colors.blueAccent : Colors.grey,
																onPressed: () {
																	setState(() { widget.matchData.position = (widget.matchData.position == 0) ? -1 : 0; });
																	_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Blue 2'),
																color: (widget.matchData.position == 1) ? Colors.blueAccent : Colors.grey,
																onPressed: () {
																	setState(() { widget.matchData.position = (widget.matchData.position == 1) ? -1 : 1; });
																	_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);
																}
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text('Blue 3'),
																color: (widget.matchData.position == 2) ? Colors.blueAccent : Colors.grey,
																onPressed: () {
																	setState(() { widget.matchData.position = (widget.matchData.position == 2) ? -1 : 2; });
																	_getTeam(int.tryParse(widget.matchData.matchNumber) ?? -1, widget.matchData.position);
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
																widget.matchData.teamNumber = input;
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
																	Navigator.push(context, new MaterialPageRoute(builder: (context) => AutonPath(matchData: widget.matchData)));
																},
															),
															VerticalDivider(width: 5.0),
															RaisedButton(
																child: Text("Teleop"),
																onPressed: () {
																	Navigator.push(context, new MaterialPageRoute(builder: (context) => Teleop(matchData: widget.matchData)));
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
																		widget.matchData.numberClimbedWith = 0;
																	} else if(climbCount == 1) {
																		climbColor = Colors.blue;
																		widget.matchData.numberClimbedWith = 1;
																	} else  {
																		climbColor = Colors.yellow;
																		widget.matchData.numberClimbedWith = 2;
																	}
																	climbPartnercount = 'Climbed with ' + widget.matchData.numberClimbedWith.toString();
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
																		Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => ScoutMode(nextMatch:  nextMatch, initials: widget.matchData.initials, position: widget.matchData.position, schedule: widget.schedule)));
																	} else {
																		print('Not clearing...');
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
		int teamNumber = widget.matchData.teamNumber == '' ? 0 : int.parse(widget.matchData.teamNumber);
		int matchNumber = widget.matchData.matchNumber == '' ? 0 : int.parse(widget.matchData.matchNumber);

		_generateId(teamNumber, matchNumber);

		if (formKey.currentState.validate()) {
			formKey.currentState.save();

			var payload = widget.matchData.toJson();
			print(jsonEncode(payload));
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

	void _getTeam (int matchNumber, int position) {
		if (schedule == null) { return; }

		setState(() {
			int teamNumber = schedule[matchNumber][position];
			if (teamNumber <= 0) {
				_teamnumbercontroller.text = '';
				widget.matchData.teamNumber = '';
			} else {
				_teamnumbercontroller.text = teamNumber.toString();
				widget.matchData.teamNumber = teamNumber.toString();
			}
		});
	}

	void _generateId(int teamNumber, int matchNumber) {
		int id = teamNumber * 10000 + matchNumber;
		widget.matchData.id = id;
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
