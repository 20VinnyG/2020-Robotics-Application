import 'package:flutter/material.dart';

class Shot {

	Offset pos;
	bool shotType = true;
	int shotsMade = -1;

	Shot ();

	Shot.fromJson (Map<String,dynamic> json) :
		pos = new Offset(json['po'][0].toDouble(), json['po'][1].toDouble()),
		shotType = json['st'] != 0,
		shotsMade = json['sm'];

	Map<String,dynamic> toJson () => {
		'po': [pos.dx.round(), pos.dy.round()],
		'st': shotType ? 1 : 0,
		'sm': shotsMade
	};

}