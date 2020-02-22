import 'package:flutter/material.dart';
import 'package:frc1640scoutingframework/match.dart';
import 'package:frc1640scoutingframework/shot.dart';
import 'package:sqflite/sqflite.dart';

class ScoutDatabaseHelper {

  static final _dbName = 'scoutmobile-2020-v0.db';
  static final _dbVersion = 1;

  ScoutDatabaseHelper._privateConstructor();
  static final ScoutDatabaseHelper instance = ScoutDatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database == null) { _database = await openDatabase(_dbName, version: _dbVersion, onCreate: _onCreate); }
    return _database;
  }

  Future _onCreate (Database db, int version) async {
    // Create table of events...
    await db.execute('''
      CREATE TABLE `schedule` (
        `event` TEXT,
        `match` INTEGER,
        `red1` INTEGER,
        `red2` INTEGER,
        `red3` INTEGER,
        `blue1` INTEGER,
        `blue2` INTEGER,
        `blue3` INTEGER
      );
    ''');
  }

  Future<List<String>> getEvents () async {
    Database db = await instance.database;
    List<Map<String,dynamic>> results = await db.rawQuery('SELECT DISTINCT `event` FROM `schedule` ORDER BY `event` ASC;');
    List<String> events = [];
    for (int i = 0; i < results.length; i++) {
      events.add(results[i]['event']);
    }
    return events;
  }

  Future createEventTables (String name) async {
    Database db = await instance.database;

    await db.execute('''
      CREATE TABLE `${name}_match` (
        `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `initials` TEXT,
        `position` INTEGER,
        `matchNumber` INTEGER,
        `teamNumber` INTEGER,
        `preloadedFuelCells` INTEGER,
        `climbTime` REAL,
        `park` INTEGER,
        `levelability` INTEGER,
        `assist` INTEGER,
        `typeAssist` INTEGER,
        `generalSuccess` REAL,
        `defensiveSuccess` REAL,
        `accuracy` REAL,
        `floorPickup` INTEGER,
        `fouls` INTEGER,
        `problems` INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE `${name}_shots` (
        `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `teamNumber` INTEGER,
        `matchNumber` INTEGER,
        `phase` TEXT,
        `sequence` INTEGER,
        `shotType` INTEGER,
        `shotsMade` INTEGER,
        `x` REAL,
        `y` REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE `${name}_path` (
        `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `teamNumber` INTEGER,
        `matchNumber` INTEGER,
        `sequence` INTEGER,
        `x` REAL,
        `y` REAL
      );
    ''');
  }

  Future addMatchData (String event, MatchData matchData) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    Map<String,dynamic> data = {
      'initials': matchData.initials,
      'position': matchData.position,
			'matchnumber': int.parse(matchData.matchNumber),
      'teamnumber': int.parse(matchData.teamNumber),
			'preloadedfuelcells': matchData.preloadedfuelcells,
      'climbTime': matchData.climbtime,
      'park': matchData.park,
      'levelability': matchData.levelability ? 1 : 0,
      'assist': matchData.assist ? 1 : 0,
      'typeAssist': matchData.typeassist ? 1 : 0,
			'generalsuccess': matchData.generalSuccess,
			'defensivesuccess': matchData.defensiveSuccess,
			'accuracy': matchData.accuracy,
			'floorpickup': matchData.floorpickup ? 1 : 0,
			'fouls': matchData.fouls ? 1 : 0,
			'problems': matchData.problems ? 1 : 0
    };

    batch.insert('${event}_match', data, conflictAlgorithm: ConflictAlgorithm.replace);

    _addShots(event, batch, matchData);
    _addPath(event, batch, matchData);

    await batch.commit(continueOnError: true, noResult: true);
  }

  Future _addShots (String event, Batch batch, MatchData matchData) async {
    List<Shot> shotList = matchData.autoshots;
    int nTeam = int.parse(matchData.teamNumber);
    int nMatch = int.parse(matchData.matchNumber);

    for (int i = 0; i < shotList.length; i++) {
      Map<String,dynamic> data = {
        'teamNumber': nTeam,
        'matchNumber': nMatch,
        'phase': 'auton',
        'sequence': (i + 1),
        'shotType': shotList[i].shotType ? 1 : 0,
        'shotsMade': shotList[i].shotsMade,
        'x': shotList[i].pos.dx,
        'y': shotList[i].pos.dy
      };
      batch.insert('${event}_shots', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    shotList = matchData.teleopshots;

    for (int i = 0; i < shotList.length; i++) {
      Map<String,dynamic> data = {
        'teamNumber': nTeam,
        'matchNumber': nMatch,
        'phase': 'teleop',
        'sequence': (i + 1),
        'shotType': shotList[i].shotType ? 1 : 0,
        'shotsMade': shotList[i].shotsMade,
        'x': shotList[i].pos.dx,
        'y': shotList[i].pos.dy
      };
      batch.insert('${event}_shots', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future _addPath (String event, Batch batch, MatchData matchData) async {
    List<Offset> path = matchData.autopathpoints;
    int nTeam = int.parse(matchData.teamNumber);
    int nMatch = int.parse(matchData.matchNumber);

    for (int i = 0; i < path.length; i++) {
      Map<String,dynamic> data = {
        'teamNumber': nTeam,
        'matchNumber': nMatch,
        'sequence': (i + 1),
        'x': path[i].dx,
        'y': path[i].dy
      };
      batch.insert('${event}_path', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

}