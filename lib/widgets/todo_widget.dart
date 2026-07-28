import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/dialoges/todo_creator.dart';
import 'package:structured_todo_list/dialoges/todo_delete_warning.dart';
import 'package:structured_todo_list/dialoges/todo_editor.dart';
import 'package:structured_todo_list/src/todo.dart';

class TodoWidget extends StatelessWidget {
  const TodoWidget({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (event) => /*textfieldKey.currentState?.changeState(false),*/ (),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - 48,
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
                    icon: const WindowsIcon(WindowsIcons.add, size: ICON_SIZE),
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
                SizedBox(width: 8.0),
                IconButton(
                  icon: const WindowsIcon(WindowsIcons.delete, size: ICON_SIZE),
                  onPressed: () => showTodoDeleteWarning(context, id: todo.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
