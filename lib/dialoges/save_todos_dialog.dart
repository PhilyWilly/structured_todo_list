import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db/database_manager.dart';

/// Shows a dialog to ask the user if they want to save the todos before proceeding.
///
/// Returns a [Future] that resolves to `true` if the user wants to save, `false` if they don't want to save, and `null` if they cancel the operation.
Future<void> saveTodosDialog(BuildContext context, int id) async {
  final bool? result = await showDialog<bool?>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('ToDos Speichern?'),
      content: const Text(
        'Sie sind dabei vorzufahren ohne zu speichern. Möchten Sie die ToDos speichern?',
      ),
      actions: [
        FilledButton(
          child: const Text('Speichern'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        Button(
          child: const Text('Nicht speichern'),
          onPressed: () => Navigator.pop(context, false),
        ),
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
    ),
  );
  if (result == true) {
    await DatabaseManager.instance.saveDatabase();
  }
}
