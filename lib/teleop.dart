import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frc1640scoutingframework/match.dart';
import 'package:frc1640scoutingframework/spin.dart';
import "shot.dart";

class Teleop extends StatefulWidget {
	// final List<Shot> teleopshotsList;
	final MatchData matchData;

	@override
	_TeleopState createState() => _TeleopState();

	Teleop({ this.matchData });
}

bool val = true;

class _TeleopState extends State<Teleop> {

	Offset screenPos;

	void onTapDown(BuildContext context, TapDownDetails details) {
		final RenderBox box = context.findRenderObject();
		final Offset localOffset = box.globalToLocal(details.globalPosition);
		screenPos = localOffset;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
				body: new GestureDetector(
					child: new Stack(
						children: <Widget>[
							new Container(
								decoration: new BoxDecoration(
										image: new DecorationImage(
												image: new AssetImage('assets/images/field.png'),
												fit: BoxFit.fill)),
							),
							new CustomPaint(
								painter: new MyPainter(shotList: widget.matchData.teleopshots),
								size: Size.infinite,
							)
						],
					),
			onTapDown: (TapDownDetails details) => onTapDown(context, details),
			onTap: () async {
				await _buildShotPrompt();
				setState(() {});
			},
			onPanUpdate: (DragUpdateDetails details) {
				final RenderBox box = context.findRenderObject();
				final Offset localOffset = box.globalToLocal(details.globalPosition);
				screenPos = localOffset;
			},
			onPanEnd: (DragEndDetails details) {
				_buildShotPrompt();
			},
      onLongPress: () {_buildSpinnerPrompt();},
		));
	}

	_buildShotPrompt () {
		Shot newShot = new Shot();
		newShot.pos = screenPos;
		return showDialog(
				context: context,
				builder: (context) {
					return StatefulBuilder(builder: (context, setState) {
						return AlertDialog(
							title: Text("Enter Number of Balls Made"),
							content: Column(
								children: _buildShotInfoEntryLayout(newShot, setState),
								mainAxisAlignment: MainAxisAlignment.center,
								mainAxisSize: MainAxisSize.min,
							)
						);
				});	
			});
	}

  _buildSpinnerPrompt () {
		Spin newSpin = new Spin();
		return showDialog(
				context: context,
				builder: (context) {
					return StatefulBuilder(builder: (context, setState) {
						return AlertDialog(
							title: Text("Enter Number of Balls Made"),
							content: Column(
								children: <Widget>[
                  RaisedButton(
                    child: Text(newSpin.controlType ? "Position Control": "Rotation Control"),
                    color: newSpin.controlType ? Colors.greenAccent : Colors.grey,
                    onPressed: () {
                      setState(() {
                        newSpin.controlType = !newSpin.controlType; 
                      }
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text(newSpin.succesful ? "Successful": "Failed"),
                    color: newSpin.succesful ? Colors.greenAccent : Colors.grey,
                    onPressed: () {
                      setState(() {
                        newSpin.succesful = !newSpin.succesful; 
                      }
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text("Done"),
                    onPressed: () {
                      widget.matchData.spins.add(newSpin);
                      Navigator.pop(context);
                    },
                  )
                ],
								mainAxisAlignment: MainAxisAlignment.center,
								mainAxisSize: MainAxisSize.min,
							)
						);
				});	
			});
	}

	List<Widget> _buildShotInfoEntryLayout (Shot newShot, Function setState) {
		return <Widget>[
			Row(
				children: <Widget>[
					_buildShotButton(newShot, 0, setState),
					VerticalDivider(width: 5.0),
					_buildShotButton(newShot, 1, setState),
					VerticalDivider(width: 5.0),
					_buildShotButton(newShot, 2, setState),
				],
				mainAxisAlignment: MainAxisAlignment.center,
			),
			Row(
				children: <Widget>[
					_buildShotButton(newShot, 3, setState),
					VerticalDivider(width: 5.0),
					_buildShotButton(newShot, 4, setState),
					VerticalDivider(width: 5.0),
					_buildShotButton(newShot, 5, setState)
				],
				mainAxisAlignment: MainAxisAlignment.center,
			),
			Divider(	height: 30.0, indent: 5.0, color: Colors.black),
			Text('Shot on which goal?'),
			RaisedButton(
				child: Text(newShot.shotType ? 'High' : 'Low'),
				onPressed: () { setState(() { newShot.shotType = !newShot.shotType; }); }
			),
			Divider(	height: 30.0, indent: 5.0, color: Colors.black),
			RaisedButton(
				child: Text('Save'),
				onPressed: (newShot.shotsMade != -1) ? () {
					setState(() { widget.matchData.teleopshots.add(newShot); });
					Navigator.pop(context);
				} : null
			)
		];
	}

	RaisedButton _buildShotButton (Shot newShot, int count, Function setState) {
		return RaisedButton(
			child: Text(count.toString()),
			color: newShot.shotsMade == count ? Colors.greenAccent : Colors.grey,
			onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == count) ? -1 : count; }); }
		);
	}

}

class MyPainter extends CustomPainter {

	final double _circleRadius = 20.0;
	final double _halfRadius = 10.0;

	List<Shot> shotList;

	MyPainter({this.shotList});
	
	@override
	void paint(Canvas canvas, Size size) {
		for (int i = 0; i < shotList.length; i++) {
			Offset shotPos = shotList[i].pos;
			int shotsMade = shotList[i].shotsMade;

			canvas.drawCircle(shotPos, _circleRadius, Paint()..color = Colors.yellow);

			TextPainter tp = TextPainter(
				text: TextSpan(text: '$shotsMade', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
				textAlign: TextAlign.center,
				textDirection: TextDirection.ltr,
			)..layout(maxWidth: size.width);
			
			tp.paint(canvas, Offset(shotPos.dx - _halfRadius, shotPos.dy - _halfRadius));
		}
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) => true;
}