import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:frc1640scoutingframework/match.dart';
import "shot.dart";

class Teleop extends StatefulWidget {
	// final List<Shot> teleopshotsList;
	final MatchData matchData;

	@override
	_TeleopState createState() => _TeleopState();

	Teleop({
		this.matchData
	});
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
												fit: BoxFit.cover)),
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
      onPanEnd: (DragEndDetails details) async {
        await _buildShotPrompt();
        setState(() {});
      }
		));
	}

  Future<T> _buildShotPrompt<T> () async {
    Shot newShot = new Shot();
		newShot.pos = screenPos;
		return showDialog(
				context: context,
				builder: (context) {
					return StatefulBuilder(builder: (context, setState) {
						return AlertDialog(
							title: Text("Enter Number of Balls Made"),
							content: Column(
								children: <Widget>[
									Row(
										children: <Widget>[
											RaisedButton(
												child: Text('0'),
												color: newShot.shotsMade == 0 ? Colors.greenAccent : Colors.grey,
												onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == 0) ? -1 : 0; }); }
											),
											VerticalDivider(width: 5.0),
											RaisedButton(
												child: Text('1'),
												color: newShot.shotsMade == 1 ? Colors.greenAccent : Colors.grey,
												onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == 1) ? -1 : 1; }); }
											),
											VerticalDivider(width: 5.0),
											RaisedButton(
												child: Text('2'),
												color: newShot.shotsMade == 2 ? Colors.greenAccent : Colors.grey,
												onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == 2) ? -1 : 2; }); }
											),
										],
										mainAxisAlignment: MainAxisAlignment.center,
									),
									Row(
										children: <Widget>[
											RaisedButton(
												child: Text('3'),
												color: newShot.shotsMade == 3 ? Colors.greenAccent : Colors.grey,
												onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == 3) ? -1 : 3; }); }
											),
											VerticalDivider(width: 5.0),
											RaisedButton(
												child: Text('4'),
												color: newShot.shotsMade == 4 ? Colors.greenAccent : Colors.grey,
												onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == 4) ? -1 : 4; }); }
											),
											VerticalDivider(width: 5.0),
											RaisedButton(
												child: Text('5'),
												color: newShot.shotsMade == 5 ? Colors.greenAccent : Colors.grey,
												onPressed: () { setState(() { newShot.shotsMade = (newShot.shotsMade == 5) ? -1 : 5; }); }
											)
										],
										mainAxisAlignment: MainAxisAlignment.center,
									),
									Divider(
										height: 30.0,
										indent: 5.0,
										color: Colors.black,
									),
									Text('Shot on which goal?'),
									RaisedButton(
										child: Text(newShot.shotType ? 'High' : 'Low'),
										onPressed: () { setState(() { newShot.shotType = !newShot.shotType; }); }
									),
									Divider(
										height: 30.0,
										indent: 5.0,
										color: Colors.black,
									),
									RaisedButton(
										child: Text('Save'),
										onPressed: (newShot.shotsMade != -1) ? () {
											setState(() { widget.matchData.teleopshots.add(newShot); });
											Navigator.pop(context);
										} : null
									)
								],
								mainAxisAlignment: MainAxisAlignment.center,
								mainAxisSize: MainAxisSize.min,
							)
						);
				});	
			});
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