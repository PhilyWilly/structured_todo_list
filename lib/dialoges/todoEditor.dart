import 'package:fluent_ui/fluent_ui.dart' hide Row;
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:structured_todo_list/db.dart';

Map<int, String> getAllTodoNames() {
  final ResultSet todoResultSet = db.select('SELECT title, id FROM todos');
  return Map.fromEntries(
    todoResultSet.map((e) => MapEntry(e['id'] as int, e['title'] as String)),
  );
}

int getParent(int id) {
  final ResultSet todoResultSet = db.select(
    'SELECT parent FROM todo_relations WHERE child == ? LIMIT 1',
    [id],
  );
  if (todoResultSet.isEmpty) {
    return -1;
  }
  return todoResultSet[0]['parent'] ?? -1;
}

void showTodoEditor(BuildContext context, int id) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ResultSet todoResultSet = db.select(
    'SELECT * FROM todos WHERE id == ? LIMIT 1',
    [id],
  );
  titleController.text = todoResultSet[0]['title'];
  descriptionController.text = todoResultSet[0]['description'] ?? "";
  final Map<int, String> todos = getAllTodoNames();
  todos.addAll({-1: "Keine"});
  todos.removeWhere((key, value) => key == id);
  int selectedParentTodo = getParent(id);
  final ValueNotifier<int> selectedParentTodoNotifier = ValueNotifier<int>(
    selectedParentTodo,
  );

  final bool result =
      await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Todo bearbeiten'),
          content: Form(
            child: IntrinsicHeight(
              child: Column(
                spacing: 12.0,
                children: [
                  InfoLabel(
                    label: 'Geben Sie den Titel ein:',
                    child: TextFormBox(
                      controller: titleController,
                      placeholder: 'Titel',
                      expands: false,
                    ),
                  ),
                  InfoLabel(
                    label: 'Geben Sie die Beschreibung ein:',
                    child: TextFormBox(
                      controller: descriptionController,
                      placeholder: 'Beschreibung',
                      maxLines: 4,
                    ),
                  ),
                  InfoLabel(
                    label: 'Wählen Sie die Todo über dieser Todo',
                    child: ValueListenableBuilder<int>(
                      valueListenable: selectedParentTodoNotifier,
                      builder: (context, currentValue, _) => ComboBox<int>(
                        value: currentValue,
                        items: todos.entries
                            .map(
                              (entry) => ComboBoxItem(
                                child: Text(entry.value),
                                value: entry.key,
                              ),
                            )
                            .toList(),
                        onChanged: (todo) {
                          if (todo == null) {
                            throw Exception("No todo found");
                          }
                          selectedParentTodoNotifier.value = todo;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              child: const Text('Änderung speichern'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            Button(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ) ??
      false;
  if (result) {
    // get the final selected parent from the notifier
    selectedParentTodo = selectedParentTodoNotifier.value;

    db.execute('UPDATE todos SET title = ?, description = ? WHERE id == ?', [
      titleController.text,
      descriptionController.text,
      id,
    ]);
    if (getParent(id) != selectedParentTodo) {
      db.execute('DELETE FROM todo_relations WHERE child == ?', [id]);
      if (selectedParentTodo != -1) {
        db.execute('INSERT INTO todo_relations (parent, child) VALUES (?, ?)', [
          selectedParentTodo,
          id,
        ]);
      }
    }
    dbVersion.value++;
    selectedParentTodoNotifier.dispose();
  }
}
