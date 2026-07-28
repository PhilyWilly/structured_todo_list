import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/dialoges/todo_creator.dart';
import 'package:structured_todo_list/dialoges/todo_delete_warning.dart';
import 'package:structured_todo_list/dialoges/todo_editor.dart';
import 'package:structured_todo_list/src/todo.dart';

class TodoWidget extends StatelessWidget {
  TodoWidget({super.key, required this.todo});

  final Todo todo;
  final FlyoutController flyoutController = FlyoutController();

  void showPriorityFlyout() {
    flyoutController.showFlyout<void>(
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.topCenter,
      ),
      barrierDismissible: true,
      dismissOnPointerMoveAway: false,
      dismissWithEsc: true,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              leading: WindowsIcon(WindowsIcons.circle_fill, color: Colors.red),
              text: const Text('High priority'),
              onPressed: () {
                todo.setPriority(3);
                Flyout.of(context).close();
              },
            ),
            MenuFlyoutItem(
              leading: WindowsIcon(
                WindowsIcons.circle_fill,
                color: Colors.yellow,
              ),
              text: const Text('Medium priority'),
              onPressed: () {
                todo.setPriority(2);
                Flyout.of(context).close();
              },
            ),
            MenuFlyoutItem(
              leading: WindowsIcon(
                WindowsIcons.circle_fill,
                color: Colors.green,
              ),
              text: const Text('Low priority'),
              onPressed: () {
                todo.setPriority(1);
                Flyout.of(context).close();
              },
            ),
            MenuFlyoutItem(
              leading: const WindowsIcon(WindowsIcons.circle_ring),
              text: const Text('No priority'),
              onPressed: () {
                todo.setPriority(null);
                Flyout.of(context).close();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    late final Color color;
    final int alpha = 69; // Adjust the alpha value as needed
    switch (todo.priority) {
      case 3:
        color = Colors.red.withAlpha(alpha);
        break;
      case 2:
        color = Colors.yellow.withAlpha(alpha);
        break;
      case 1:
        color = Colors.green.withAlpha(alpha);
        break;
      default:
        color = Colors.transparent;
    }
    return MouseRegion(
      onExit: (event) => /*textfieldKey.currentState?.changeState(false),*/ (),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - 48,
        child: Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 450,
                    child: Text(
                      todo.title,
                      style: FluentTheme.of(context).typography.bodyLarge,
                    ),
                  ),
                  // SizedBox(width: 6.0),
                  // if (description.isNotEmpty)
                  //   Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //     child: Text(
                  //       todo.description,
                  //       style: FluentTheme.of(context).typography.body,
                  //     ),
                  //   ),
                ],
              ),
              Row(
                children: [
                  if (todo.getProgress() > 0 && todo.getProgress() < 100)
                    Row(
                      children: [
                        Row(
                          spacing: 12.0,
                          children: [
                            ProgressBar(value: todo.getProgress()),
                            Text("${todo.getProgress().floor()}%"),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(width: 16.0),
                  MouseRegion(
                    onEnter: (event) => (),

                    // textfieldKey.currentState?.changeState(true),
                    child: IconButton(
                      icon: const WindowsIcon(
                        WindowsIcons.add,
                        size: ICON_SIZE,
                      ),
                      onPressed: () => showTodoCreator(context, id: todo.id),
                    ),
                  ),
                  // AnimatingTextfield(
                  //   key: textfieldKey,
                  //   onSubmitted: (result) =>
                  //       createTodo(result, parent: todo.id),
                  // ),
                  // SizedBox(width: 8.0),
                  IconButton(
                    icon: const WindowsIcon(WindowsIcons.edit, size: ICON_SIZE),
                    onPressed: () => showTodoEditor(context, id: todo.id),
                  ),
                  FlyoutTarget(
                    controller: flyoutController,
                    child: IconButton(
                      icon: const WindowsIcon(
                        WindowsIcons.filter,
                        size: ICON_SIZE,
                      ),
                      onPressed: () => showPriorityFlyout(),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  IconButton(
                    icon: const WindowsIcon(
                      WindowsIcons.delete,
                      size: ICON_SIZE,
                    ),
                    onPressed: () =>
                        showTodoDeleteWarning(context, id: todo.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
