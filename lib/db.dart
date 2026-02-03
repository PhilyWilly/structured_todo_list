library;

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqlite3/sqlite3.dart';

late Database db = sqlite3.open("data/sqlite/todos.db");

final ValueNotifier<int> dbVersion = ValueNotifier<int>(0);

/// Export the current database file to [destPath].
Future<void> exportDatabaseToPath(String destPath) async {
  final File src = File('data/sqlite/todos.db');
  if (!await src.exists()) {
    throw Exception('Source database not found at data/sqlite/todos.db');
  }
  final File dest = File(destPath);
  await dest.parent.create(recursive: true);
  await src.copy(dest.path);
}

/// Import a database from [srcPath] by replacing the current database file
/// and re-opening the database connection.
Future<void> importDatabaseFromPath(String srcPath) async {
  final File src = File(srcPath);
  if (!await src.exists()) {
    throw Exception('Import source file does not exist: $srcPath');
  }

  // Close existing connection
  try {
    db.dispose();
  } catch (_) {}

  final File dest = File('data/sqlite/todos.db');
  await dest.parent.create(recursive: true);
  await src.copy(dest.path);

  // Re-open database
  db = sqlite3.open(dest.path);

  // Notify listeners that DB changed
  dbVersion.value++;
}
