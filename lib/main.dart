import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db.dart';
import 'package:structured_todo_list/pages/home_page.dart';

void initializeDatabase() {
  db.execute('''
    CREATE TABLE todos (
      id INTEGER NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      finished BOOL NOT NULL DEFAULT FALSE,
      expanded BOOL NOT NULL DEFAULT TRUE,
      deleted BOOL NOT NULL DEFAULT FALSE
    );
  ''');
  db.execute('''
    CREATE TABLE todo_relations (
      parent INTEGER NOT NULL,
      child INTEGER NOT NULL PRIMARY KEY,
      deleted BOOL NOT NULL DEFAULT FALSE
    );
  ''');
}

void main() {
  // initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Strukturierte ToDo Liste',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.purple,
      ),
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
