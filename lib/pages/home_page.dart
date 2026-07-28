import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqlite3/sqlite3.dart' hide Row;
import 'package:structured_todo_list/db/database_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:structured_todo_list/dialoges/save_todos_dialog.dart';
import 'package:structured_todo_list/dialoges/todo_creator.dart';
import 'package:structured_todo_list/src/todo.dart';
import 'package:structured_todo_list/widgets/custom_tree_view.dart';
import 'package:structured_todo_list/widgets/todo_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> todos = [];
  List<int> selection = [];
  SortingMethod sortingMethod = SortingMethod.byPriority;

  Iterable<int> getToplevelTodoIdx() {
    final ResultSet todoResultSet = DatabaseManager.instance.select(''' 
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

  void _showSortingDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Sortieren'),
        content: Column(
          spacing: 4.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Button(
              child: const Text('Nach Priorität sortieren'),
              onPressed: () {
                setState(() {
                  sortingMethod = SortingMethod.byPriority;
                });
                Navigator.pop(context);
              },
            ),
            Button(
              child: const Text('Nach Fortschritt sortieren'),
              onPressed: () {
                setState(() {
                  sortingMethod = SortingMethod.byProgress;
                });
                Navigator.pop(context);
              },
            ),
            Button(
              child: const Text('Nach Titel sortieren'),
              onPressed: () {
                setState(() {
                  sortingMethod = SortingMethod.byTitle;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
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
          const CommandBarSeparator(),
          CommandBarButton(
            icon: const WindowsIcon(WindowsIcons.sort),
            label: const Text('Sortieren'),
            tooltip: 'Todos nach Priorität, Fortschritt oder Titel sortieren',
            onPressed: () => _showSortingDialog(),
          ),
        ],
      ),

      content: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 24.0, top: 8.0),
        child: Column(
          spacing: 12.0,
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: DatabaseManager.instance.dbVersion,
                builder: (context, value, child) {
                  print("DB Version changed: $value");
                  final todos = getToplevelTodoObj().toList();
                  todos.sort((a, b) {
                    switch (sortingMethod) {
                      case SortingMethod.byPriority:
                        return (b.getPriority()).compareTo(a.getPriority());
                      case SortingMethod.byProgress:
                        return b.getProgress().compareTo(a.getProgress());
                      case SortingMethod.byTitle:
                        return a.title.compareTo(b.title);
                    }
                  });

                  return CustomTreeView(
                    items: todos,
                    onItemSelected: (item, selected) {
                      final todo = item as Todo;
                      todo.setProgress(selected);
                    },
                    itemBuilder: (item) {
                      return TodoWidget(todo: item as Todo);
                    },
                  );
                },
              ),
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

enum SortingMethod { byPriority, byProgress, byTitle }
