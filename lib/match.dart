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
}