import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqlite3/sqlite3.dart' hide Row;
import 'package:structured_todo_list/db/database_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:structured_todo_list/dialoges/save_todos_dialog.dart';
import 'package:structured_todo_list/dialoges/todo_creator.dart';
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
    final ResultSet todoResultSet = DatabaseManager.instance.db.select(''' 
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
    return retObj;
  }

  Todo getTodoFromId(int inputId) {
    for (Todo todo in getToplevelTodoObj()) {
      Todo? childResult = todo.getChildFromId(inputId);
      if (childResult != null) {
        return childResult;
      }
    }
    throw Exception("To child with id found");
  }

  Future<void> newDatabase() async {
    final bool result = await showSaveTodosDialog(context);
    if (!result) return;
    await DatabaseManager.instance.wipeDatabase();
  }

  Future<void> openDatabase() async {
    final bool result = await showSaveTodosDialog(context);
    if (!result) return;
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
      await DatabaseManager.instance.openDatabaseFromPath(
        srcPath,
      ); // Import logic
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

  Future<void> saveDatabaseAs() async {
    // Let the user pick a directory to save the DB copy into
    try {
      String? directory = await FilePicker.platform.saveFile(
        dialogTitle: 'Speichern unter',
        fileName: 'todos.db',
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
      );
      if (directory == null || directory.isEmpty) return;
      if (!directory.endsWith('.db') && !directory.endsWith('.sqlite')) {
        directory += '.db'; // Append .db if no extension is provided
      }
      await DatabaseManager.instance.saveDatabaseToPath(
        directory,
      ); // Make the export
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

  Future<void> saveDatabase() async {
    // Save the database to the current path
    try {
      await DatabaseManager.instance.saveDatabase();
    } catch (e) {
      if (!mounted) return;
      showDialog<void>(
        // Zeige fehlgeschlagender Export Dialog
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Speichern fehlgeschlagen'),
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
              newDatabase();
            },
          ),
          const CommandBarSeparator(),
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.folder_open),
            label: const Text('Öffnen'),
            tooltip: 'Importieren Sie eine Datenbank',
            onPressed: openDatabase,
          ),
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.save),
            label: const Text('Speichern'),
            tooltip: 'Exportieren Sie die Datenbank',
            onPressed: saveDatabase,
          ),
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.save_as),
            label: const Text('Speichern unter'),
            tooltip: 'Exportieren Sie die Datenbank',
            onPressed: saveDatabaseAs,
          ),
        ],
      ),

      content: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 24.0, top: 8.0),
        child: Column(
          spacing: 12.0,
          children: [
            ValueListenableBuilder(
              valueListenable: DatabaseManager.instance.dbVersion,
              builder: (context, value, child) {
                print("DB Version changed: $value");
                final todos = getToplevelTodoObj().toList();

                return TreeView(
                  selectionMode: TreeViewSelectionMode.multiple,
                  shrinkWrap: true,
                  onSecondaryTap: (item, details) async {
                    debugPrint(
                      'onSecondaryTap $item at ${details.globalPosition}',
                    );
                  },
                  items: todos.map((e) => e.toTree(context)).toList(),
                );
              },
            ),
            Button(
              onPressed: () {
                showTodoCreator(context);
              },
              child: Row(
                spacing: 8.0,
                children: [
                  const WindowsIcon(WindowsIcons.add),
                  const Text('Neue Todo erstellen'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
