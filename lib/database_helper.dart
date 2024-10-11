// database_helper.dart

import 'dart:async';
import 'dart:io'; // Needed for FileImage in ReportDialog
import 'package:sqflite/sqflite.dart';
import 'package:clup_management/person.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  // Singleton Pattern Implementation
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  static const int _dbVersion = 3;
  static const String _dbName = 'club_management.db';
  static const String _tableName = 'persons';

  /// Getter for the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDatabase();
      debugPrint('Database initialized');
      return _database!;
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, _dbName);
      debugPrint('Database path: $path');

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error in _initDatabase: $e');
      rethrow;
    }
  }

  /// Creates the database tables
  FutureOr<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $_tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firstName TEXT NOT NULL,
          lastName TEXT NOT NULL,
          age INTEGER NOT NULL,
          imagePath TEXT,
          isFavorite INTEGER NOT NULL DEFAULT 0,
          fee REAL NOT NULL DEFAULT 1000,
          startDate TEXT NOT NULL,
          duration TEXT NOT NULL
        )
      ''');
      debugPrint('Table "$_tableName" created with new fields');
    } catch (e) {
      debugPrint('Error creating table: $e');
      rethrow;
    }
  }

  /// Handles database upgrades
  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('''
          ALTER TABLE $_tableName ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0
        ''');
        debugPrint('Added "isFavorite" column to "$_tableName" table');
      } catch (e) {
        debugPrint('Error adding "isFavorite" column: $e');
      }
    }

    if (oldVersion < 3) {
      try {
        await db.execute('''
          ALTER TABLE $_tableName ADD COLUMN fee REAL NOT NULL DEFAULT 1000
        ''');
        debugPrint('Added "fee" column to "$_tableName" table');
      } catch (e) {
        debugPrint('Error adding "fee" column: $e');
      }

      try {
        await db.execute('''
          ALTER TABLE $_tableName ADD COLUMN startDate TEXT NOT NULL DEFAULT ''
        ''');
        debugPrint('Added "startDate" column to "$_tableName" table');
      } catch (e) {
        debugPrint('Error adding "startDate" column: $e');
      }

      try {
        await db.execute('''
          ALTER TABLE $_tableName ADD COLUMN duration TEXT NOT NULL DEFAULT 'One Month'
        ''');
        debugPrint('Added "duration" column to "$_tableName" table');
      } catch (e) {
        debugPrint('Error adding "duration" column: $e');
      }
    }
  }

  /// Inserts a new person into the database
  Future<int> insertPerson(Person person) async {
    try {
      final db = await database;
      return await db.insert(
        _tableName,
        person.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error inserting person: $e');
      return -1; // Indicates failure
    }
  }

  /// Retrieves all persons from the database
  Future<List<Person>> getAllPersons() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      return List.generate(maps.length, (i) {
        return Person.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('Error retrieving all persons: $e');
      return [];
    }
  }

  /// Retrieves favorite persons from the database
  Future<List<Person>> getFavoritePersons() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'isFavorite = ?',
        whereArgs: [1],
      );

      return List.generate(maps.length, (i) {
        return Person.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('Error retrieving favorite persons: $e');
      return [];
    }
  }

  /// Deletes a person from the database by ID
  Future<int> deletePerson(int id) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting person: $e');
      return -1; // Indicates failure
    }
  }

  /// Updates a person's details in the database
  Future<int> updatePerson(Person person) async {
    try {
      final db = await database;
      return await db.update(
        _tableName,
        person.toMap(),
        where: 'id = ?',
        whereArgs: [person.id],
      );
    } catch (e) {
      debugPrint('Error updating person: $e');
      return -1; // Indicates failure
    }
  }

  /// Toggles the favorite status of a person
  Future<int> toggleFavorite(Person person) async {
    person.isFavorite = !person.isFavorite;
    return await updatePerson(person);
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  /// Retrieves persons whose registration has expired
  Future<List<Person>> getExpiredPersons() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      DateTime today = DateTime.now();
      List<Person> expiredPersons = [];

      for (var map in maps) {
        Person person = Person.fromMap(map);
        DateTime startDate = DateFormat('yyyy-MM-dd').parse(person.startDate);
        int durationMonths = durationToMonths(person.duration);
        DateTime endDate = DateTime(startDate.year, startDate.month + durationMonths, startDate.day);

        if (endDate.isBefore(today)) {
          expiredPersons.add(person);
        }
      }

      return expiredPersons;
    } catch (e) {
      debugPrint('Error retrieving expired persons: $e');
      return [];
    }
  }

  /// Retrieves persons whose registration is about to expire within [days] days
  Future<List<Person>> getExpiringPersons(int days) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      DateTime today = DateTime.now();
      DateTime targetDate = today.add(Duration(days: days));
      List<Person> expiringPersons = [];

      for (var map in maps) {
        Person person = Person.fromMap(map);
        DateTime startDate = DateFormat('yyyy-MM-dd').parse(person.startDate);
        int durationMonths = durationToMonths(person.duration);
        DateTime endDate = DateTime(startDate.year, startDate.month + durationMonths, startDate.day);

        if (endDate.isAfter(today) && endDate.isBefore(targetDate)) {
          expiringPersons.add(person);
        }
      }

      return expiringPersons;
    } catch (e) {
      debugPrint('Error retrieving expiring persons: $e');
      return [];
    }
  }

  /// Helper method to convert duration string to number of months
  int durationToMonths(String duration) {
    switch (duration.toLowerCase()) {
      case 'one month':
        return 1;
      case 'three months':
        return 3;
      case 'six months':
        return 6;
      case 'one year':
        return 12;
      default:
        return 1; // Default to 1 month if unknown
    }
  }
}
