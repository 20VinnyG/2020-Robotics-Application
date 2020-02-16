import 'package:flutter/material.dart';
import 'shot.dart';

class MatchData {
  //Pregame
  String initials = '';
  int position;
  int matchNumber;
  int teamNumber;
  double initiationlinepos = 0;
  int preloadedfuelcells;
  int id;
  //Auton
  List<Offset> autopathpoints = [];
  List<int> autopathx = [];
  List<int> autopathy = [];
  List<Shot> autoshots = [];
  //Telop
  List<Shot> teleopshots = [];
  //Endgame
  double climbtime=0;
  int park;
  bool levelability = false;
  bool assist = false;
  bool typeassist = false;
  //Postgame
  double generalSuccess =  0;
  double defensiveSuccess =0;
  double accuracy = 0;
  bool floorpickup = false;
  bool fouls = false;
  bool problems = false;
}