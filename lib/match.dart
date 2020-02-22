import 'package:flutter/material.dart';
import 'shot.dart';

class MatchData {

	// Pregame
	String initials = '';
	int position = -1;
	String matchNumber = '';
	String teamNumber = '';
	double initiationlinepos = 0;
	int preloadedfuelcells = 0;
	// int id;

	// Auton
	List<Offset> autopathpoints = [];
	List<int> autopathx = [];
	List<int> autopathy = [];
	List<Shot> autoshots = [];

	//Telop
	List<Shot> teleopshots = [];

	// Endgame
	double climbtime=0;
	int park = 3; // TODO: Convert to int 1-3 before QR
	bool levelability = false;
	bool assist = false;
	bool typeassist = false;

	// Postgame
	double generalSuccess =	0;
	double defensiveSuccess =0;
	double accuracy = 0;
	bool floorpickup = false;
	bool fouls = false;
	bool problems = false;

  // Helper methods

	Map<String,dynamic> toMap () {
		return {
			'initials': initials,
			'teamnumber': teamNumber,
			'matchnumber': matchNumber,
			'initiationposition': initiationlinepos,
			'preloadedfuelcells': preloadedfuelcells,
			// 'autopathx': autopathx,
			// 'autopathy': autopathy,
			// 'autoshotsx': autoshotsx,
			// 'autoshotsy': autoshotsy,
			// 'autoshotsmade': autoshotsmade,
			// 'autoshotstype': autoshotstype,
			// 'teleopshotsx': teleopshotsx,
			// 'teleopshotsy': teleopshotsy,
			// 'teleopshotsmade': teleopshotsmade,
			// 'teleopshotstype': teleopshotstype,
			'generalsuccess': generalSuccess,
			'defensivesuccess': defensiveSuccess,
			'accuracy': accuracy,
			'floorpickup': floorpickup ? 1 : 0,
			'fouls': fouls ? 1 : 0,
			'problems': problems ? 1 : 0
		};
	}

  Iterable<String> getKeys () {
    return toMap().keys;
  }

}