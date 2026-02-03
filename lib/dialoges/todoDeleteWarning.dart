import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db.dart';

void showTodoDeleteWarning(BuildContext context, int id) async {
  final bool result =
      await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Todo löschen?'),
          content: const Text(
            'Wenn Sie diese Todo löschen, werden auch alle darunter liegenden Todos gelöscht!',
          ),
          actions: [
            FilledButton(
              child: const Text('Löschen'),
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
    db.execute("UPDATE todos SET deleted = TRUE WHERE id == ?", [id]);
    // db.execute("DELETE FROM todo_relations WHERE parent == ?", [id]);
    // db.execute("DELETE FROM todo_relations WHERE child == ?", [id]);
    dbVersion.value++;
  }
}
