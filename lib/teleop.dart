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

	onSwitchValueChanged(bool newVal) {
		setState(() {
			val = newVal;
		});
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
			// floatingActionButton: SpeedDial(
			//		 animatedIcon: AnimatedIcons.menu_close,
			//		 children: [
			//			 SpeedDialChild(
			//					 backgroundColor: Colors.red,
			//					 child: Icon(Icons.clear),
			//					 label: "Clear Path",
			//					 onTap: () => points.clear()),
			//			 SpeedDialChild(
			//					 backgroundColor: Colors.green,
			//					 child: Icon(Icons.check),
			//					 label: "Completed Path",
			//					 onTap: () {
			//						 condensePoints();
			//						 Navigator.pop(context);
			//					 })
			//		 ],
			//	 ));
			onTapDown: (TapDownDetails details) => onTapDown(context, details),
			onTap: () {
				Shot newShot = new Shot();
        newShot.pos = screenPos;
				return showDialog(
						context: context,
						builder: (context) {
							return AlertDialog(
									title: Text("Enter Number of Balls Made"),
									content: Column(
                    mainAxisSize: MainAxisSize.min,
										children: <Widget>[
											DropdownButton(
												items: [
													DropdownMenuItem(
															value: int.parse("0"), child: Text("0")),
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
												],
												onChanged: (value) {
													setState(() {
														newShot.shotsMade = value;
													});
												},
												hint: Text("Balls Made"),
												value: newShot.shotsMade,
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
                            widget.matchData.teleopshots.add(newShot);
                          });
													Navigator.pop(context);
												},
											)
										],
									));
						});
			},
		));
	}
}

class MyPainter extends CustomPainter {

  List<Shot> shotList;

  MyPainter({this.shotList});
	
  @override
	void paint(Canvas canvas, Size size) {
    for (int i = 0; i < shotList.length; i++) {
      canvas.drawCircle(shotList[i].pos, 20.0, Paint()..color = Colors.yellow);
    }
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) => true;
}