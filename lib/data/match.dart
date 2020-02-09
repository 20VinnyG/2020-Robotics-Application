class MatchData {
  //Pregame
  String initials = '';
  int position;
  int matchNumber;
  int teamNumber;
  double initiationLinePosition =0;
  int preloadedFuelCells;
  int id;
  //Auton
  var path;
  var autonShots;
  //Telop
  var teleopShots;
  //Endgame
  double climbTime=0;
  int park;
  bool levelability = false;
  bool assist = false;
  bool typeAssist = false;
  //Postgame
  double generalSuccess =0;
  double defensiveSuccess=0;
  double accuracy=0;
  bool floorPickup = false;
  bool fouls = false;
  bool problems = false;
}