import 'package:flutter/material.dart';
import 'package:selfsync_frontend/feature/todos/ui/todo_list_item.dart';

import '../model/todo_model.dart';

class TodoList extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoTap;
  final Function(Todo) onTodoDelete;
  final bool todoHistory;
  const TodoList({super.key, 
  required this.todos, 
  required this.onTodoTap, 
  required this.onTodoDelete, required this.todoHistory});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.todos.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final todo = widget.todos[index];
          return TodoListItem(todo: todo, onTodoTap: widget.onTodoTap, onTodoDelete: widget.onTodoDelete, todoHistory: widget.todoHistory);
        },
      ),
    );
  }
}