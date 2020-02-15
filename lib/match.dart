import 'package:flutter/material.dart';
import 'shot.dart';

class Match {
  //Pregame
  String initials = '';
  int position;
  int matchNumber;
  int teamNumber;
  double initiationlinepos =0;
  int preloadedfuelcells;
  int id;
  //Auton
  List<int> autopathx = <int>[];
  List<int> autopathy = <int>[];
  List<Shot> autoshots = <Shot>[];
  //Telop
  List<Shot> teleopshots = <Shot>[];
  //Endgame
  double climbtime=0;
  int park;
  bool levelability = false;
  bool assist = false;
  bool typeassist = false;
  //Postgame
  double generalSuccess =0;
  double defensiveSuccess=0;
  double accuracy=0;
  bool floorpickup = false;
  bool fouls = false;
  bool problems = false;
}