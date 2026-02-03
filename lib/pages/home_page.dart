import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:structured_todo_list/db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:structured_todo_list/dialoges/todoCreator.dart';
import 'package:structured_todo_list/src/todo.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> todos = [];

  List<int> selection = [];

  Iterable<int> getToplevelTodoIdx() {
    final ResultSet todoResultSet = db.select(''' 
      SELECT todos.id AS id
      FROM todos 
      LEFT JOIN todo_relations 
      ON todos.id == todo_relations.child
      WHERE todo_relations.parent IS NULL;''');

    return todoResultSet
        .map((e) => ((e['id'] ?? -1) as int))
        .where((e) => e != -1);
  }

  Iterable<Todo> getToplevelTodoObj() {
    final retObj = getToplevelTodoIdx()
        .map((e) => Todo.fromId(e))
        .where((e) => e.deleted == false);
    // setSelectedTodos(retObj: retObj);
    // print("Selection: ${selection}");
    return retObj;
  }

  // void setSelectedTodos({Iterable<Todo>? retObj}) {
  //   retObj ??= getToplevelTodoIdx()
  //       .map((e) => Todo.fromId(e))
  //       .where((e) => e.deleted == false);
  //   selection = retObj
  //       .where((e) => e.finished == true)
  //       .map((e) => e.id)
  //       .toList();
  // }

  Todo getTodoFromId(int inputId) {
    for (Todo todo in getToplevelTodoObj()) {
      Todo? childResult = todo.getChildFromId(inputId);
      if (childResult != null) {
        return childResult;
      }
    }
    throw Exception("To child with id found");
  }

  Future<void> importDatabase() async {
    // Let the user pick a file to import

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
      );
      if (result == null || result.files.isEmpty) return;
      final String? srcPath = result.files.single.path;
      if (srcPath == null) return;
      await importDatabaseFromPath(srcPath); // Import logic
      if (!mounted) return;
      showDialog<void>(
        // Show success dialog
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Import abgeschlossen'),
          content: Text('Datenbank wurde von $srcPath importiert.'),
          actions: [
            Button(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog<void>(
        // Dialog bei Fehlgeschlagenen import
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Import fehlgeschlagen'),
          content: Text(e.toString()),
          actions: [
            Button(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> exportDatabase() async {
    // Let the user pick a directory to save the DB copy into
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null || directory.isEmpty) return;
      final destPath = '$directory/todos.db';
      await exportDatabaseToPath(destPath); // Make the export
      if (!mounted) return;
      showDialog<void>(
        // Zeige verifikations Nachricht
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Export abgeschlossen'),
          content: Text('Datenbank wurde nach $destPath exportiert.'),
          actions: [
            Button(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog<void>(
        // Zeige fehlgeschlagender Export Dialog
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Export fehlgeschlagen'),
          content: Text(e.toString()),
          actions: [
            Button(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      header: CommandBar(
        overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
        primaryItems: [
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.add),
            label: const Text('Neu'),
            tooltip: 'Erstellen Sie eine neue Todo',
            onPressed: () {
              showTodoCreator(context);
            },
          ),
          const CommandBarSeparator(),
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.download),
            label: const Text('Import'),
            tooltip: 'Importieren Sie eine Datenbank',
            onPressed: importDatabase,
          ),
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.upload),
            label: const Text('Export'),
            tooltip: 'Exportieren Sie die Datenbank',
            onPressed: exportDatabase,
          ),
        ],
      ),

      content: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 24.0, top: 8.0),
        child: ValueListenableBuilder(
          valueListenable: dbVersion,
          builder: (context, value, child) {
            final todos = getToplevelTodoObj().toList();

            return TreeView(
              selectionMode: TreeViewSelectionMode.multiple,
              shrinkWrap: true,
              onSecondaryTap: (item, details) async {
                debugPrint('onSecondaryTap $item at ${details.globalPosition}');
              },
              items: todos.map((e) => e.toTree(context)).toList(),
            );
          },
        ),
      ),
    );
  }
}
