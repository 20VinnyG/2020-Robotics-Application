import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frc1640scoutingframework/autonpath.dart';
import 'package:frc1640scoutingframework/bluealliance.dart';
import 'package:frc1640scoutingframework/teleop.dart';
//import 'package:frc1640scoutingframework/teleop.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'match.dart';
import 'shot.dart';

class ScoutMode extends StatefulWidget {
  @override
  _ScoutModeState createState() => _ScoutModeState();
}

class _ScoutModeState extends State<ScoutMode> {
  var stopwatch = new Stopwatch();
  double showntime;
  bool state = true;

  final formKey = GlobalKey<FormState>();
  Match newMatch = new Match();
  List<int> teleopshotsx = <int>[];
  List<int> teleopshotsy = <int>[];
  List<int> autoshotsx = <int>[];
  List<int> autoshotsy = <int>[];
  List<int> autoshotsmade = <int>[];
  List<int> teleopshotsmade = <int>[];
  List<bool> autoshotstype = <bool>[];
  List<bool> teleopshotstype = <bool>[];
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
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => Bluealliance()));
                            },
                          )),
                      Divider(
                        height: 30.0,
                        indent: 5.0,
                        color: Colors.black,
                      ),
                      Text("Prematch"),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter your initials',
                        ),
                        validator: (input) =>
                            input.isEmpty ? 'Not a valid input' : null,
                        onSaved: (input) => newMatch.initials = input,
                        onFieldSubmitted: (input) => newMatch.initials = input,
                        onChanged: (input) => newMatch.initials = input,
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter the match number',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (input) =>
                              input.isEmpty ? 'Not a valid input' : null,
                          onSaved: (input) =>
                              newMatch.matchNumber = int.parse(input),
                          onChanged: (input) =>
                              newMatch.matchNumber = int.parse(input),
                          onFieldSubmitted: (input) =>
                              newMatch.matchNumber = int.parse(input)),
                      DropdownButton(
                        items: [
                          DropdownMenuItem(
                              value: int.parse("1"), child: Text("Blue1")),
                          DropdownMenuItem(
                              value: int.parse("2"), child: Text("Blue2")),
                          DropdownMenuItem(
                              value: int.parse("3"), child: Text("Blue3")),
                          DropdownMenuItem(
                              value: int.parse("4"), child: Text("Red1")),
                          DropdownMenuItem(
                              value: int.parse("5"), child: Text("Red2")),
                          DropdownMenuItem(
                              value: int.parse("6"), child: Text("Red3")),
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
                        decoration: const InputDecoration(
                          hintText: "Enter Team Number",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (input) =>
                            input.isEmpty ? 'Not a valid input' : null,
                        onSaved: (input) =>
                            newMatch.teamNumber = int.parse(input),
                        onChanged: (input) =>
                            newMatch.teamNumber = int.parse(input),
                        onFieldSubmitted: (input) =>
                            newMatch.teamNumber = int.parse(input),
                      ),
                      Slider(
                        value: newMatch.initiationlinepos,
                        onChanged: (double delta) {
                          setState(() => newMatch.initiationlinepos = delta);
                        },
                        min: 0.0,
                        max: 10.0,
                        divisions: 10,
                      ),
                      DropdownButton(
                        items: [
                          DropdownMenuItem(
                              value: int.parse("1"), child: Text("1")),
                          DropdownMenuItem(
                              value: int.parse("2"), child: Text("2")),
                          DropdownMenuItem(
                              value: int.parse("3"), child: Text("3")),
                          DropdownMenuItem(
                              value: int.parse("4"), child: Text("4")),
                          DropdownMenuItem(
                              value: int.parse("5"), child: Text("5")),
                          DropdownMenuItem(
                              value: int.parse("6"), child: Text("6")),
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
                      Text("Auton"),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: RaisedButton(
                            child: Text("Auton"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => AutonPath(condensedPathx: newMatch.autopathx, condensedPathy: newMatch.autopathy, autonshotsList: newMatch.autoshots,)));
                            },
                          )),
                      Divider(
                        height: 30.0,
                        indent: 5.0,
                        color: Colors.black,
                      ),
                      Text("Teleop"),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: RaisedButton(
                            child: Text("Teleop"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => Teleop(teleopshotsList: newMatch.teleopshots)));
                            },
                          )),
                      Divider(
                        height: 30.0,
                        indent: 5.0,
                        color: Colors.black,
                      ),
                      Text("Endgame"),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: RaisedButton(
                            child: Text("Stop Climb Timer"),
                            onPressed: () {
                              stopwatch..stop();
                              newMatch.climbtime =
                                  stopwatch.elapsedMilliseconds / 1000;
                            },
                          )),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: RaisedButton(
                            child: Text("Reset Climb Timer"),
                            onPressed: () {
                              stopwatch..reset();
                            },
                          )),
                      DropdownButton(
                        items: [
                          DropdownMenuItem(
                              value: int.parse("1"), child: Text("Park")),
                          DropdownMenuItem(
                              value: int.parse("2"), child: Text("Climb")),
                          DropdownMenuItem(
                              value: int.parse("3"), child: Text("Neither")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            newMatch.park = value;
                          });
                        },
                        hint: Text("End Game State?"),
                        value: newMatch.park,
                      ),
                      Text("Level Ability?"),
                      Switch(
                        value: newMatch.levelability,
                        onChanged: (bool s) {
                          setState(() {
                            newMatch.levelability = s;
                          });
                        },
                      ),
                      Text("Assist?"),
                      Switch(
                        value: newMatch.assist,
                        onChanged: (bool s) {
                          setState(() {
                            newMatch.assist = s;
                          });
                        },
                      ),
                      Text("Active or Passive Assist?"),
                      Switch(
                        value: newMatch.typeassist,
                        onChanged: (bool s) {
                          setState(() {
                            newMatch.typeassist = s;
                          });
                        },
                      ),
                      Divider(
                        height: 30.0,
                        indent: 5.0,
                        color: Colors.black,
                      ),
                      Text("Post-Match"),
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
                          filledIconData: Icons.blur_off,
                          halfFilledIconData: Icons.blur_on,
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
                          filledIconData: Icons.blur_off,
                          halfFilledIconData: Icons.blur_on,
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
                          filledIconData: Icons.blur_off,
                          halfFilledIconData: Icons.blur_on,
                          color: Colors.blue,
                          borderColor: Colors.blue,
                          spacing: 0.0),
                      Text("Floor Pickup?"),
                      Switch(
                        value: newMatch.floorpickup,
                        onChanged: (bool s) {
                          setState(() {
                            newMatch.floorpickup = s;
                          });
                        },
                      ),
                      Text("Eggregious Fouls?"),
                      Switch(
                        value: newMatch.fouls,
                        onChanged: (bool s) {
                          setState(() {
                            newMatch.fouls = s;
                          });
                        },
                      ),
                      Text("Had Problems?"),
                      Switch(
                        value: newMatch.problems,
                        onChanged: (bool s) {
                          setState(() {
                            newMatch.problems = s;
                          });
                        },
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
                    ],
                    scrollDirection: Axis.vertical,
                  )))),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.timer),
        label: Text("Start Climb Timer"),
        onPressed: () {
          stopwatch..start();
        },
      ),
    );
  }

  void _submit() {
    //_generateId();
    _extractshootingshootingpoints();
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var payload = {
        'initials': newMatch.initials.toString(),
        'id': newMatch.id,
        'teamnumber': newMatch.teamNumber,
        'position': newMatch.position,
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
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                child: QrImage(
              data: jsonEncode(payload),
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
    int id = newMatch.teamNumber + 00 + newMatch.matchNumber;
    print(id);
    newMatch.id = id;
  }

  _extractshootingshootingpoints() {
    for(int i=0; i < newMatch.autoshots.length; i++) {
      autoshotsx.add(newMatch.autoshots[i].posx.round());
      autoshotsy.add(newMatch.autoshots[i].posy.round());
      autoshotsmade.add(newMatch.autoshots[i].shotsMade);
      autoshotstype.add(newMatch.autoshots[i].shotType);
    }
    for(int i=0; i< newMatch.autoshots.length; i++) {
      teleopshotsx.add(newMatch.teleopshots[i].posx.round());
      teleopshotsy.add(newMatch.teleopshots[i].posy.round());
      teleopshotsmade.add(newMatch.teleopshots[i].shotsMade);
      teleopshotstype.add(newMatch.teleopshots[i].shotType);
    }
    
  }
}
