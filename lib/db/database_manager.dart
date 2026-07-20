library;

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._internal();

  late Database _db;
  Database get db {
    print("Accessing database");
    dbVersion.value++;
    return _db;
  }

  String? dbPath;
  final String internalDbPath = "data/sqlite/todos.db";

  final ValueNotifier<int> _dbVersion = ValueNotifier<int>(0);
  ValueNotifier<int> get dbVersion => _dbVersion;

  factory DatabaseManager() => instance;

  DatabaseManager._internal() {
    openDatabase(internalDbPath);
  }

  void openDatabase(String path) {
    _db = sqlite3.open(path);
    dbPath = path;
  }

  Future<void> initializeDatabase() async {
    File dbFile = File(internalDbPath);
    if (!await dbFile.exists()) {
      await dbFile.parent.create(recursive: true);
    }
    _db = sqlite3.open(internalDbPath);
    final ResultSet results = _db.select('''
    SELECT name 
    FROM sqlite_schema 
    WHERE type='table' AND name NOT LIKE 'sqlite_%';
  ''');
    final List<String> existingTables = results
        .map((row) => row['name'] as String)
        .toList();
    if (!existingTables.contains('todos')) {
      _db.execute('''
        CREATE TABLE todos (
          id INTEGER NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          finished BOOL NOT NULL DEFAULT FALSE,
          expanded BOOL NOT NULL DEFAULT TRUE,
          deleted BOOL NOT NULL DEFAULT FALSE
        );
  ''');
    }
    if (!existingTables.contains('todo_relations')) {
      _db.execute('''
        CREATE TABLE todo_relations (
          parent INTEGER NOT NULL,
          child INTEGER NOT NULL PRIMARY KEY,
          deleted BOOL NOT NULL DEFAULT FALSE
        );
  ''');
    }
  }

  /// Export the current database file to [destPath].
  Future<void> saveDatabaseToPath(String destPath) async {
    final File src = File(internalDbPath);
    if (!await src.exists()) {
      throw Exception('Source database not found at $internalDbPath');
    }
    final File dest = File(destPath);
    await dest.parent.create(recursive: true);
    await src.copy(dest.path);
    dbPath = destPath;
  }

  Future<void> saveDatabase() async {
    if (dbPath == null) {
      throw Exception('Database path is not set. Cannot save database.');
    }
    saveDatabaseToPath(dbPath!);
  }

  /// Import a database from [srcPath] by replacing the current database file
  /// and re-opening the database connection.
  Future<void> openDatabaseFromPath(String srcPath) async {
    final File src = File(srcPath);
    if (!await src.exists()) {
      throw Exception('Import source file does not exist: $srcPath');
    }

    print("Before wiping database");
    await wipeDatabase(initialize: false);
    print("After wiping database");
    final File dest = File(internalDbPath);
    await src.copy(dest.path);
    print("After copying database");
    _db = sqlite3.open(dest.path);
    print("After accessing database");

    // Notify listeners that DB changed
    dbVersion.value++;
    dbPath = srcPath;
  }

  Future<void> wipeDatabase({bool initialize = true}) async {
    print("Wiping database");
    final File dest = File(internalDbPath);
    print("Database path: ${dest.path}");
    try {
      _db.close();
    } catch (_) {}
    print("Closed database connection");
    if (await dest.exists()) {
      await dest.delete();
    }
    await dest.parent.create(recursive: true);
    // Re-open database
    if (initialize) {
      _db = sqlite3.open(dest.path);
      await initializeDatabase();
    }
    dbPath = null;
    dbVersion.value++;
  }
}
