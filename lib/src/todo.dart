import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqlite3/sqlite3.dart' hide Row;
import 'package:structured_todo_list/db.dart';
import 'package:structured_todo_list/db/create_todo.dart';
import 'package:structured_todo_list/dialoges/todoCreator.dart';
import 'package:structured_todo_list/dialoges/todoDeleteWarning.dart';
import 'package:structured_todo_list/dialoges/todoEditor.dart';
import 'package:structured_todo_list/src/animating_textfield.dart';

const double ICON_SIZE = 14.0;

class Todo {
  int id;
  String title;
  String description;
  bool finished;
  bool expanded;
  bool deleted;
  List<Todo> children;

  Todo({
    required this.id,
    required this.title,
    this.description = "",
    this.finished = false,
    this.expanded = true,
    this.deleted = false,
    this.children = const [],
  });

  factory Todo.fromId(int id) {
    final ResultSet todoResultSet = db.select(
      'SELECT * FROM todos WHERE id == ? LIMIT 1',
      [id],
    );
    final ResultSet relsationResultSet = db.select(
      '''SELECT * 
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
    final List<Todo> children = relsationResultSet
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
    db.execute("UPDATE todos SET finished = ? WHERE id == ?", [
      progress == 100.0,
      id,
    ]);
    return progress;
  }

  double _getProgress() {
    if (children.isEmpty) {
      return finished ? 100.0 : 0.0;
    }
    double progress = 0.0;
    for (Todo child in children) {
      progress += child.getProgress();
    }
    return progress / children.length;
  }

  void setProgress(bool progress) {
    print("Changed progress from task $id to $progress");
    db.execute("UPDATE todos SET finished = ? WHERE id == ?", [progress, id]);

    dbVersion.value++;

    for (Todo child in children) {
      child.setProgress(progress);
    }
  }

  Todo? getChildFromId(int inputId) {
    if (inputId == id) {
      return this;
    }
    for (Todo child in children) {
      Todo? childResult = child.getChildFromId(inputId);
      if (childResult != null) {
        return childResult;
      }
    }
    return null;
  }

  TreeViewItem toTree(BuildContext context) {
    final double progress = getProgress();
    final GlobalKey<AnimatingTextfieldState> textfieldKey = GlobalKey();
    return TreeViewItem(
      content: MouseRegion(
        onExit: (event) => textfieldKey.currentState?.changeState(false),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: FluentTheme.of(context).typography.bodyLarge,
                ),
                SizedBox(width: 6.0),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: description.isNotEmpty ? 8.0 : 0.0,
                  ),
                  child: Text(
                    description,
                    style: FluentTheme.of(context).typography.body,
                  ),
                ),
                SizedBox(width: 12.0),
                MouseRegion(
                  onEnter: (event) =>
                      textfieldKey.currentState?.changeState(true),

                  child: IconButton(
                    icon: const WindowsIcon(WindowsIcons.add, size: ICON_SIZE),
                    onPressed: () => showTodoCreator(context, id: id),
                  ),
                ),
                AnimatingTextfield(
                  key: textfieldKey,
                  onSubmitted: (result) => createTodo(result, parent: id),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: const WindowsIcon(WindowsIcons.edit, size: ICON_SIZE),
                  onPressed: () => showTodoEditor(context, id),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: const WindowsIcon(WindowsIcons.delete, size: ICON_SIZE),
                  onPressed: () => showTodoDeleteWarning(context, id),
                ),
              ],
            ),
            Visibility(
              visible: progress > 0 && progress < 100,
              child: Row(
                spacing: 12.0,
                children: [
                  ProgressBar(value: progress),
                  Text("${progress.floor()}%"),
                ],
              ),
            ),
          ],
        ),
      ),
      selected: finished,
      value: id,
      onInvoked: (item, onInvoked) async {
        setProgress(item.selected ?? false);
      },
      expanded: expanded,
      onExpandToggle: (_, _) async {
        db.execute('UPDATE todos SET expanded = ? WHERE id == ?', [
          !expanded,
          id,
        ]);
        dbVersion.value++;
      },
      children: children.map((e) => e.toTree(context)).toList(),
    );
  }
}
