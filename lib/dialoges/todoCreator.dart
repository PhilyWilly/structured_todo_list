import 'package:fluent_ui/fluent_ui.dart';
import 'package:structured_todo_list/db/create_todo.dart';

void showTodoCreator(BuildContext context, {int? id}) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final bool result =
      await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Todo erstellen'),
          content: Form(
            child: IntrinsicHeight(
              child: Column(
                spacing: 12.0,
                children: [
                  InfoLabel(
                    label: 'Geben Sie den Titel ein:',
                    child: TextFormBox(
                      controller: titleController,
                      placeholder: 'Titel',
                      expands: false,
                    ),
                  ),
                  InfoLabel(
                    label: 'Geben Sie die Beschreibung ein:',
                    child: TextFormBox(
                      controller: descriptionController,
                      placeholder: 'Beschreibung',
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              child: const Text('Erstellen'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            Button(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ) ??
      false;
  if (result) {
    createTodo(
      titleController.text,
      description: descriptionController.text,
      parent: id,
    );
  }
}
