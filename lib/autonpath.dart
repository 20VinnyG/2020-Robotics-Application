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
									Offset _localPosition = object.globalToLocal(details.globalPosition);
									points.add(_localPosition);
								});
							},
							onPanEnd: (DragEndDetails details) async {
								Shot newShot = new Shot();
								newShot.pos = points[points.length - 1];
								await showDialog(
									context: context,
									builder: (context) {
										return StatefulBuilder(builder: (context, setState) {
											return AlertDialog(
												title: Text("Enter Number of Balls Made"),
												content: Column(
													children: _buildShotInfoEntryLayout (newShot, setState),
													mainAxisAlignment: MainAxisAlignment.center,
													mainAxisSize: MainAxisSize.min,
												)
											);
									});	
							});
              setState(() {});
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
									Navigator.pop(context);
								})
					],
				));
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
					setState(() { widget.matchData.autoshots.add(newShot); });
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

class AutoPath extends CustomPainter {

	final double _circleRadius = 20.0;
	final double _halfRadius = 10.0;

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
