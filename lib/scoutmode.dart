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

class ScoutMode extends StatefulWidget {
  final List autonpath;
  final List teleopshots;
  ScoutMode({Key key, this.autonpath, this.teleopshots}) : super(key: key);
  @override
  _ScoutModeState createState() => _ScoutModeState();
}

class _ScoutModeState extends State<ScoutMode> {
  final formKey = GlobalKey<FormState>();
  Match newMatch = new Match();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Scout Mode"), backgroundColor: Colors.blue[900]),
        body: new Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your initials',
                          ),
                          validator: (input) =>
                              input.isEmpty ? 'Not a valid input' : null,
                          onSaved: (input) => newMatch.initials = input,
                          onFieldSubmitted: (input) =>
                              newMatch.initials = input,
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
                            hintText: 'Enter the team number',
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
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: RaisedButton(
                              child: Text("Auton"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => AutonPath()));
                              },
                            )),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: RaisedButton(
                              child: Text("Test Pipeline"),
                              onPressed: () {
                                print("${widget.autonpath}");
                              },
                            )),
                        Divider(
                          height: 30.0,
                          indent: 5.0,
                          color: Colors.black,
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: RaisedButton(
                              child: Text("Teleop"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => Teleop()));
                              },
                            )),
                        Divider(
                          height: 30.0,
                          indent: 5.0,
                          color: Colors.black,
                        ),
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
                            color: Colors.green,
                            borderColor: Colors.green,
                            spacing: 0.0),
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
                            color: Colors.green,
                            borderColor: Colors.green,
                            spacing: 0.0),
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
                            color: Colors.green,
                            borderColor: Colors.green,
                            spacing: 0.0),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: RaisedButton(
                              child: Text("Generate QR"),
                              onPressed: _submit,
                            )),
                      ],
                      scrollDirection: Axis.vertical,
                    )))));
  }

  void _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var payload = {
        'initials': newMatch.initials,
        'teamnumber': newMatch.teamNumber,
        'position': newMatch.position,
        'matchnumber': newMatch.matchNumber,
        'initiationposition': newMatch.initiationlinepos,
        'preloadedfuelcells': newMatch.preloadedfuelcells,
        'generalsuccess': newMatch.generalSuccess,
        'defensivesuccess': newMatch.defensiveSuccess,
        'accuracy': newMatch.accuracy,
        'path': newMatch.path
      };
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text("Generated QR"),
                content: QrImage(
                  data: payload.toString(),
                ));
          });
    }
  }

  void _getTeam() {
    var scheduledTeam;
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
    scheduledTeam = int.parse(scheduledTeam.substring(3));
    print(scheduledTeam);
  }
}
