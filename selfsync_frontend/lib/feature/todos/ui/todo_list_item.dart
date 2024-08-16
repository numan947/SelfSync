import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/todo_model.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final Function(Todo) onTodoTap;
  final Function(Todo) onTodoDelete;
  final bool todoHistory;
  const TodoListItem(
      {super.key,
      required this.todo,
      required this.onTodoTap,
      required this.onTodoDelete,
      required this.todoHistory});

  @override
  Widget build(BuildContext context) {
    final String dateAdded = DateFormat.yMMMd().format(todo.dateAdded);
    final String dueDate = DateFormat.yMMMd().format(todo.dueDate);
    Color? tileColor = Colors.grey[200];
    bool isSameDay = todo.dueDate.year == DateTime.now().year &&
        todo.dueDate.month == DateTime.now().month &&
        todo.dueDate.day == DateTime.now().day;
    
    if (isSameDay) {
      tileColor = Colors.yellow[100];
    }else{
      if (todo.dueDate.isBefore(DateTime.now())) {
        tileColor = Colors.red[100];
      }else{
        tileColor = const Color.fromARGB(255, 236, 233, 246);
      }
    }

    if (todoHistory) {
      tileColor = Colors.white;
    }

    return Card(
      color: tileColor,
      child: ListTile(
        leading:Checkbox(value: todoHistory, onChanged: (value){
          onTodoTap(todo);
          }),
        title: Row(
          children: [
            todo.isLocal ? const Icon(Icons.cloud_off, color: Colors.red,) : const Icon(Icons.cloud_done, color: Colors.green,),
            const SizedBox(width: 5),
            Text(todo.title, style: TextStyle(
              decoration: todoHistory ? TextDecoration.lineThrough : TextDecoration.none
            )),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 5),
                const Icon(Icons.create),
                const SizedBox(width: 5),
                Text(dateAdded, style: TextStyle(color: Colors.indigo, decoration: todoHistory ? TextDecoration.lineThrough : TextDecoration.none)),
              ],
            ),
            if (dueDate.isNotEmpty)
              Row(
                children: [
                  const SizedBox(width: 5),
                  if (dueDate.isNotEmpty) const Icon(Icons.calendar_today),
                  if (dueDate.isNotEmpty) const SizedBox(width: 5),
                  if (dueDate.isNotEmpty) Text(dueDate, style: TextStyle(color: Colors.teal, decoration: todoHistory ? TextDecoration.lineThrough : TextDecoration.none)),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onTodoDelete(todo),
        ),
        onLongPress: () => onTodoDelete(todo),
      ));
  }
}
