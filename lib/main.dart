import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db/database_manager.dart';
import 'package:structured_todo_list/pages/home_page.dart';

Future<void> initializeDatabase() {
  return DatabaseManager.instance.initializeDatabase();
}

void main() {
  initializeDatabase();
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
