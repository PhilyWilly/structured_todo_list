import 'package:structured_todo_list/db/database_manager.dart';

void createTodo(String title, {String description = "", int? parent}) {
  DatabaseManager.instance.db.execute(
    'INSERT INTO todos (title, description) VALUES (?,?)',
    [title, description],
  );
  if (parent != null) {
    final int newTaskId = DatabaseManager.instance.db.lastInsertRowId;
    DatabaseManager.instance.db.execute(
      'INSERT INTO todo_relations (parent, child) VALUES (?, ?)',
      [parent, newTaskId],
    );
  }
}
