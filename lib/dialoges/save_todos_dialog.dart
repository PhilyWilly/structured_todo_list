import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db/database_manager.dart';

/// Displays a dialog to ask the user if they want to save their todos before proceeding
///
/// Returns a Future<bool> that resolves to true if the user chooses to save or not save, and false if they cancel the action.
Future<bool> showSaveTodosDialog(BuildContext context) async {
  final entries =
      DatabaseManager.instance.db
              .select('SELECT COUNT(*) AS count FROM todos WHERE deleted = 0;')
              .first['count']
          as int;
  if (entries == 0) return true;
  final bool? result = await showDialog<bool?>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('ToDos Speichern?'),
      content: const Text(
        'Sie sind dabei vorzufahren ohne zu speichern. Möchten Sie die ToDos speichern?',
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
        Button(
          child: const Text('Nicht speichern'),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text('Speichern'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    ),
  );
  if (result == true) {
    try {
      await DatabaseManager.instance.saveDatabase();
    } catch (e) {
      String? directory = await FilePicker.platform.saveFile(
        dialogTitle: 'Speichern unter',
        fileName: 'todos.db',
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
      );
      if (directory == null || directory.isEmpty) return false;
      if (!directory.endsWith('.db') && !directory.endsWith('.sqlite')) {
        directory += '.db'; // Append .db if no extension is provided
      }
      await DatabaseManager.instance.saveDatabaseToPath(
        directory,
      ); // Make the export
    }
    return true;
  }
  if (result == false) {
    return true;
  }
  if (result == null) {
    return false;
  }
  return false;
}
