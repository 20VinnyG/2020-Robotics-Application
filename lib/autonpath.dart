import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:frc1640scoutingframework/match.dart';
import 'package:frc1640scoutingframework/shot.dart';

class AutonPath extends StatefulWidget {
	final MatchData matchData;

	@override
	AutonPathState createState() => AutonPathState();

	AutonPath({this.matchData});
}

class AutonPathState extends State<AutonPath> {
	int group;
	@override
	Widget build(BuildContext context) {
		List<Offset> points = widget.matchData.autopathpoints;

		return new Scaffold(
				body: new Stack(children: <Widget>[
					Container(
						decoration: new BoxDecoration(
								image: new DecorationImage(
										image: new AssetImage('assets/images/field.png'),
										fit: BoxFit.cover)),
					),
					new GestureDetector(
							onPanUpdate: (DragUpdateDetails details) {
								setState(() {
									RenderBox object = context.findRenderObject();
									Offset _localPosition =
											object.globalToLocal(details.globalPosition);
									points.add(_localPosition);
								});
							},
							onPanEnd: (DragEndDetails details) {
								Shot newShot = new Shot();
								newShot.pos = points[points.length - 1];
								return showDialog(
										context: context,
										builder: (context) {
											return StatefulBuilder(builder: (context, setState) {
												return AlertDialog(
														title: Text("Enter Number of Balls Made"),
														content: Column(
															mainAxisSize: MainAxisSize.min,
															children: <Widget>[
																RadioListTile(
																	value: 0,
																	title: Text("0 Shots Made"),
																	activeColor: Colors.black,
																	groupValue: group,
																	onChanged: (int e) {
																		setState(() {
																			newShot.shotsMade = e;
																			group = e;
																			print(newShot.shotsMade);
																		});
																	},
																),
																RadioListTile(
																	value: 1,
																	title: Text("1 Shot Made"),
																	activeColor: Colors.black,
																	groupValue: group,
																	onChanged: (int e) {
																		setState(() {
																			newShot.shotsMade = e;
																			group = e;
																			print(newShot.shotsMade);
																		});
																	},
																),
																RadioListTile(
																	value: 2,
																	title: Text("2 Shots Made"),
																	activeColor: Colors.black,
																	groupValue: group,
																	onChanged: (int e) {
																		setState(() {
																			newShot.shotsMade = e;
																			group = e;
																			print(newShot.shotsMade);
																		});
																	},
																),
																RadioListTile(
																	value: 3,
																	title: Text("3 Shots Made"),
																	activeColor: Colors.black,
																	groupValue: group,
																	onChanged: (int e) {
																		setState(() {
																			newShot.shotsMade = e;
																			group = e;
																			print(newShot.shotsMade);
																		});
																	},
																),
																RadioListTile(
																	value: 4,
																	title: Text("4 Shots Made"),
																	activeColor: Colors.black,
																	groupValue: group,
																	onChanged: (int e) {
																		setState(() {
																			newShot.shotsMade = e;
																			group = e;
																			print(newShot.shotsMade);
																		});
																	},
																),
																RadioListTile(
																	value: 5,
																	title: Text("5 Shots Made"),
																	activeColor: Colors.black,
																	groupValue: group,
																	onChanged: (int e) {
																		setState(() {
																			newShot.shotsMade = e;
																			group = e;
																			print(newShot.shotsMade);
																		});
																	},
																),
																Switch(
																	value: newShot.shotType,
																	onChanged: (bool s) {
																		setState(() {
																			newShot.shotType = s;
																		});
																	},
																),
																RaisedButton(
																	child: Text("Done"),
																	onPressed: () {
																		setState(() {
																			widget.matchData.autoshots.add(newShot);
																		});
																		Navigator.pop(context);
																	},	
																)
															],
														));
										});
							},
							child: new CustomPaint(
								painter: new AutoPath(points: widget.matchData.autopathpoints, shotList: widget.matchData.autoshots),
								size: Size.infinite,
							)),
				]),
				floatingActionButton: SpeedDial(
					animatedIcon: AnimatedIcons.menu_close,
					children: [
						SpeedDialChild(
								backgroundColor: Colors.red,
								child: Icon(Icons.clear),
								label: "Clear Path and Shots",
								onTap: () => {
									points.clear(),
									widget.matchData.autoshots.clear()
								}),
						SpeedDialChild(
								backgroundColor: Colors.green,
								child: Icon(Icons.check),
								label: "Completed Path",
								onTap: () {
									condensePoints();
									Navigator.pop(context);
								})
					],
				));
	}

	condensePoints() {
		List<Offset> points = widget.matchData.autopathpoints;
		widget.matchData.autopathx = [];
		widget.matchData.autopathy = [];
		for (int i = 0; i < points.length; i += 5) {
			widget.matchData.autopathx.add(points[i].dx.round());
			widget.matchData.autopathy.add(points[i].dy.round());
		}
		/*if (points.last = null) {
			// != mod value - 1
			widget.condensedPathx.add(points.last.dx.round());
			widget.condensedPathy.add(points.last.dy.round());
		}
		*/
	}
}

class AutoPath extends CustomPainter {
	List<Offset> points;
	List<Shot> shotList;
	AutoPath({this.points, this.shotList});

	@override
	void paint(Canvas canvas, Size size) {
		Paint paint = new Paint()
			..color = Colors.blue
			..strokeCap = StrokeCap.round
			..strokeWidth = 5.0;

		for (int i = 0; i < points.length - 1; i++) {
			if (points[i] != null && points[i + 1] != null) {
				canvas.drawLine(points[i], points[i + 1], paint);
			}
		}

		for (int i = 0; i < shotList.length; i++) {
			canvas.drawCircle(shotList[i].pos, 20.0, Paint()..color = Colors.yellow);
		}
	}

	@override
	bool shouldRepaint(AutoPath oldDelegate) =>
			true; // oldDelegate.points.length != points.length;
}
