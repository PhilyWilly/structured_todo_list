import 'package:sqlite3/sqlite3.dart' hide Row;
import 'package:structured_todo_list/db/database_manager.dart';
import 'package:structured_todo_list/widgets/custom_tree_view.dart';

const double ICON_SIZE = 14.0;

class Todo extends CustomTreeViewItem {

  Todo({
    required super.id,
    required super.title,
    super.description = "",
    super.finished = false,
    super.expanded = true,
    super.deleted = false,
    super.children = const [],
  });

  factory Todo.fromId(int id) {
    final ResultSet todoResultSet = DatabaseManager.instance.select(
      'SELECT * FROM todos WHERE id == ? LIMIT 1',
      [id],
    );
    final ResultSet relationResultSet = DatabaseManager.instance.select(
      '''SELECT child
      FROM todo_relations 
      JOIN todos
      ON todos.id == todo_relations.child
      WHERE todo_relations.parent == ? 
      AND todos.deleted == FALSE
      ''',
      [id],
    );
    final todoResult = todoResultSet[0];
    final String title = todoResult['title'];
    final String description = todoResult['description'] ?? "";
    final bool finished = todoResult['finished'] == 1 ? true : false;
    final bool expanded = todoResult['expanded'] == 1 ? true : false;
    final bool deleted = todoResult['deleted'] == 1 ? true : false;
    final List<Todo> children = relationResultSet
        .map((e) => Todo.fromId(e['child']))
        .toList();

    return Todo(
      id: id,
      title: title,
      description: description,
      finished: finished,
      expanded: expanded,
      deleted: deleted,
      children: children,
    );
  }

  double getProgress() {
    final double progress = _getProgress();
    DatabaseManager.instance.silentdb.execute(
      "UPDATE todos SET finished = ? WHERE id == ?",
      [progress == 100.0, id],
    );
    print("Progress for Todo $id ($title): $progress%");
    return progress;
  }

  double _getProgress() {
    if (children.isEmpty) {
      return finished ? 100.0 : 0.0;
    }
    double progress = 0.0;
    for (final child in children) {
      progress += (child as Todo).getProgress();
    }
    return progress / children.length;
  }

  void setProgress(bool progress) {
    DatabaseManager.instance.db.execute(
      "UPDATE todos SET finished = ? WHERE id == ?",
      [progress, id],
    );

    for (final child in children) {
      (child as Todo).setProgress(progress);
    }
  }

  Todo? getChildFromId(int inputId) {
    if (inputId == id) {
      return this;
    }
    for (final child in children) {
      Todo? childResult = (child as Todo).getChildFromId(inputId);
      if (childResult != null) {
        return childResult;
      }
    }
    return null;
  }
}
