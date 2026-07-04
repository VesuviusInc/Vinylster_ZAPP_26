import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vinylster_zapp_26/data/models/game_history.dart';
import 'package:vinylster_zapp_26/data/models/game_history_player.dart';

class HistoryDatabaseHelper {
  static HistoryDatabaseHelper? _historyDatabaseHelper;
  static Database? _database;

  HistoryDatabaseHelper._createInstance();

  factory HistoryDatabaseHelper() {
    if(_historyDatabaseHelper == null) {
      _historyDatabaseHelper = HistoryDatabaseHelper._createInstance();
    }
    return _historyDatabaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'gameHistory.db';
    await deleteDatabase(path);
    var historyDatabase = await openDatabase(path, version: 1, onCreate: _createTables);
    return historyDatabase;
  }

  void _createTables(Database db, int newVersion) async {
    if(_database == null) {
      await db.execute(
          'CREATE TABLE gamePlayerHistory(name TEXT, gameID TEXT, PRIMARY KEY (name, gameID))'
      );
      await db.execute(
          'CREATE TABLE gameHistory(gameID TEXT PRIMARY KEY, time TEXT, playerAmount INTEGER)'
      );
    }
  }

  Future<void> insertGameHistory(GameHistory gameHistory) async {
    final db = await database;

    await db.insert(
      'gameHistory',
      gameHistory.toMap(),
    );
  }

  Future<void> insertGameHistoryPlayer(GameHistoryPlayer gameHistoryPlayer) async {
    final db = await database;

    await db.insert(
      'gamePlayerHistory',
      gameHistoryPlayer.toMap(),
    );
  }


  Future<List<GameHistory>> getGames() async {
    final db = await database;

    final List<Map<String, Object?>> gameHistoryMaps = await db.query('gameHistory');

    return [
      for (final {'gameID': gameID as String, 'time': time as String, 'playerAmount': playerAmount as int} in gameHistoryMaps)
        GameHistory(gameID: gameID, time: time, playerAmount: playerAmount),
    ];
  }

  Future<List<GameHistoryPlayer>> getPlayersByGame(String gameID) async {
    final db = await database;

    final List<Map<String, Object?>> gameHistoryPlayerMaps = await db.query('gamePlayerHistory', where: 'gameID = "${gameID}"');

    return [
      for (final {'gameID': gameID as String, 'name': name as String} in gameHistoryPlayerMaps)
        GameHistoryPlayer(gameID: gameID, name: name),
    ];
  }

}