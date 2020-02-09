import 'package:frc1640scoutingframework/data/match.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  
  static final _databaseName = "ScoutMobile.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  final Future<Database> _database = openDatabase(_databaseName, version: _databaseVersion);

  // static Database _database;
  // Future<Database> get database async {
  //   if (_database != null) { return _database; }
  //   _database = await openDatabase(_databaseName, version: _databaseVersion);
  //   return _database;
  // }

  Future<void> addEvent (String eventName) async {
    (await _database).execute('''
      CREATE TABLE IF NOT EXISTS ? (
        initials TEXT,
        position INTEGER,
        matchNumber INTEGER,
        teamNumber INTEGER,
        initiationLinePosition REAL,
        preloadedFuelCells INTEGER,
        id INTEGER,
        path TEXT,
        autonShots TEXT,
        teleopShots TEXT,
        climbTime REAL,
        park INTEGER,
        levelability INTEGER,
        assist INTEGER,
        typeAssist INTEGER,
        generalSuccess REAL,
        defensiveSuccess REAL,
        accuracy REAL,
        floorPickup INTEGER,
        fouls INTEGER,
        problems INTEGER
      );
    ''', [eventName]);
  }

  Future<void> insertMatchData (String eventName, MatchData matchData) async {
    (await _database).rawInsert('''
      INSERT OR IGNORE into ? (
        initials,
        position,
        matchNumber,
        teamNumber,
        initiationLinePosition,
        preloadedFuelCells,
        id,
        path,
        autonShots,
        teleopShots,
        climbTime,
        park,
        levelability,
        assist,
        typeAssist,
        generalSuccess,
        defensiveSuccess,
        accuracy,
        floorPickup,
        fouls,
        problems
      ) 
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
    ''', [
      matchData.initials,
      matchData.position,
      matchData.matchNumber,
      matchData.teamNumber,
      matchData.initiationLinePosition,
      matchData.preloadedFuelCells,
      matchData.id,
      matchData.path.toString(),
      matchData.autonShots.toString(),
      matchData.teleopShots.toString(),
      matchData.climbTime,
      matchData.levelability ? 1 : 0,
      matchData.assist ? 1 : 0,
      matchData.typeAssist ? 1 : 0,
      matchData.generalSuccess,
      matchData.defensiveSuccess,
      matchData.accuracy,
      matchData.floorPickup ? 1 : 0,
      matchData.fouls ? 1 : 0,
      matchData.problems ? 1 : 0
    ]);
  }

  Future<List<MatchData>> getAllMatchDataForEvent (String eventName) async {

    

    var matches = [];

    return matches;
  } 

}