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
  var path;
  var autoshots;
  //Telop
  var teleopshots;
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