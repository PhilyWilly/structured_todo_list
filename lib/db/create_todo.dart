import 'package:structured_todo_list/db.dart';

void createTodo(String title, {String description = "", int? parent}) {
  db.execute('INSERT INTO todos (title, description) VALUES (?,?)', [
    title,
    description,
  ]);
  if (parent != null) {
    final int newTaskId = db.lastInsertRowId;
    db.execute('INSERT INTO todo_relations (parent, child) VALUES (?, ?)', [
      parent,
      newTaskId,
    ]);
  }
  dbVersion.value++;
}
