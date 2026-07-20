import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db/database_manager.dart';
import 'package:structured_todo_list/dialoges/save_todos_dialog.dart';
import 'package:structured_todo_list/pages/home_page.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initializeDatabase() async {
  await DatabaseManager.instance.wipeDatabase();
  await DatabaseManager.instance.initializeDatabase();
}

Future<void> initializeWindowManager() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    title: "My Todo App",
    // This tells the OS: "Don't kill the process yet, let Dart handle it"
    skipTaskbar: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  await initializeWindowManager();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // 2. Register this class to listen for window close signals
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    // 3. Clean up the listener when destroyed
    windowManager.removeListener(this);
    super.dispose();
  }

  // 4. Override this exact method to catch the Windows 'X' button click
  @override
  void onWindowClose() async {
    // Check if the window is already flagged to close to avoid infinite loops
    bool isPreventClose = await windowManager.isPreventClose();

    if (isPreventClose) {
      final BuildContext? ctx = _navigatorKey.currentContext;
      if (ctx == null) return; // not ready yet, bail safely

      // Run your custom dialog logic
      final bool result = await showSaveTodosDialog(ctx);

      if (!result) {
        // User clicked cancel/stay -> stop everything, keep app open
        return;
      }

      // User confirmed -> strip the protection and shut down the native process cleanly
      await windowManager.setPreventClose(false);
      await windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      navigatorKey: _navigatorKey,
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
