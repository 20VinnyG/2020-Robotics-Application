import 'package:flutter/material.dart';
import 'shot.dart';
import 'spin.dart';

class MatchData {

	//Pregame
	String initials = '';
	int position = -1;
	String matchNumber = '';
	String teamNumber = '';
	int preloadedfuelcells = 0;
	int id;

	//Auton
	List<Offset> autopathpoints = [];
	List<Offset> autopathpointscondensed = [];
	List<int> autopathx = [];
	List<int> autopathy = [];
	List<Shot> autoshots = [];

	//Telop
	List<Shot> teleopshots = [];
	Spin spins = new Spin();

	//Endgame
	double climbtime=0;
	int park = 3; // TODO: Convert to int 1-3 before QR
	bool levelability = false;
	bool assist = false;
	bool typeassist = false;

	//Postgame
	double generalSuccess =	0;
	double defensiveSuccess =0;
	double accuracy = 0;
	bool floorpickup = true;
	bool fouls = false;
	bool problems = false;

	MatchData ();

	MatchData.fromJson (Map<String,dynamic> json) {
		initials = json['in'];
		position = json['po'];
		matchNumber = json['mn'];
		teamNumber = json['tn'];
		preloadedfuelcells = json['fc'];
		id = json['id'];
		autopathpointscondensed = [];// autopathpointscondensed - later
		autoshots = [];// autoshots - later
		teleopshots = [];// teleopshots - later
		spins = Spin.fromJson(json['sp']);
		climbtime = json['ct'];
		park = json['pa'];
		levelability = json['la'] != 0;
		assist = json['at'] != 0;
		typeassist = json['ta'] != 0;
		generalSuccess = json['gs'];
		defensiveSuccess = json['ds'];
		accuracy = json['ac'];
		floorpickup = json['fp'] != 0;
		fouls = json['fo'] != 0;
		problems = json['pr'] != 0;

		List<dynamic> autopathpointsFromJson = json['ap'];
		for (int i = 0; i < autopathpointsFromJson.length; i++) {
			autopathpointscondensed.add(Offset(autopathpointsFromJson[i][0].toDouble(), autopathpointsFromJson[i][1].toDouble()));
		}

		List<dynamic> autoshotsFromJson = json['as'];
		for (int i = 0; i < autoshotsFromJson.length; i++) {
			autoshots.add(Shot.fromJson(autoshotsFromJson[i]));
		}

		List<dynamic> teleopshotsFromJson = json['ts'];
		for (int i = 0; i < teleopshotsFromJson.length; i++) {
			teleopshots.add(Shot.fromJson(teleopshotsFromJson[i]));
		}
	}

	Map<String,dynamic> toJson () {

		double gs = (generalSuccess * 2).roundToDouble() / 2;
		if (gs <= 1e-10) { generalSuccess = null; }
		double ds = (defensiveSuccess * 2).roundToDouble() / 2;
		if (ds <= 1e-10) { defensiveSuccess = null; }
		double ac = (accuracy * 2).roundToDouble() / 2;
		if (ac <= 1e-10) { accuracy = null; }

		Map<String,dynamic> map = {
			'in': initials,
			'po': position,
			'mn': matchNumber,
			'tn': teamNumber,
			'fc': preloadedfuelcells,
			'id': id,
			// autopathpointscondensed - manual
			// autoshots - manual
			// teleopshots - manual
			'sp': spins.toJson(),
			'ct': climbtime,
			'pa': park,
			'la': levelability ? 1 : 0,
			'at': assist ? 1 : 0,
			'ta': typeassist ? 1 : 0,
			'gs': gs,
			'ds': ds,
			'ac': ac,
			'fp': floorpickup ? 1 : 0,
			'fo': fouls ? 1 : 0,
			'pr': problems ? 1 : 0
		};

		List<List<int>> autopathpointsForJson = [];
		for (int i = 0; i < autopathpointscondensed.length; i++) {
			autopathpointsForJson.add([autopathpointscondensed[i].dx.round(), autopathpointscondensed[i].dy.round()]);
		}
		map['ap'] = autopathpointsForJson;

		List<Map<String,dynamic>> autoshotsForJson = [];
		for (int i = 0; i < autoshots.length; i++) {
			autoshotsForJson.add(autoshots[i].toJson());
		}
		map['as'] = autoshotsForJson;

		List<Map<String,dynamic>> teleopshotsForJson = [];
		for(int i = 0; i < teleopshots.length; i++) {
			teleopshotsForJson.add(teleopshots[i].toJson());
		}
		map['ts'] = teleopshotsForJson;

		return map;
	}

}