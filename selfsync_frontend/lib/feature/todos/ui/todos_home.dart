import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/common/ui/custom_search_bar.dart';
import 'package:selfsync_frontend/feature/todos/bloc/todo_bloc.dart';
import 'package:selfsync_frontend/feature/todos/cubit/addtodo_cubit.dart';
import 'package:selfsync_frontend/feature/todos/ui/todo_list.dart';
import 'package:selfsync_frontend/main.dart';

import '../model/todo_model.dart';

class TodosHome extends StatefulWidget {
  const TodosHome({super.key});

  @override
  State<TodosHome> createState() => _TodosHomeState();
}

class _TodosHomeState extends State<TodosHome> {
  late TextEditingController _todoTitleController;
  late StreamSubscription _subscription;
  late StreamSubscription _internetSubscription;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(FetchTodos());

    _todoTitleController = TextEditingController();
    _subscription = eventBus.on<TodosUpdatedEvent>().listen((event) {
      context
          .read<TodoBloc>()
          .add(TodosSynced(currentIndex)); // this will refresh the todos
    });
    _internetSubscription =
        eventBus.on<InternetConnectedEvent>().listen((event) {
      context.read<TodoBloc>().add(TodoListInternetConnected(currentIndex));
    });
  }

  @override
  void dispose() {
    _todoTitleController.dispose();
    _subscription.cancel();
    _internetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        // print('State: $state');
        if (state is TodoError) {
          return Center(
            child: Text(state.message),
          );
        }

        if (state is TodoLoaded ||
            state is TodoHistoryLoaded ||
            state is TodoEmpty) {
          currentIndex = state is TodoLoaded
              ? state.index
              : state is TodoHistoryLoaded
                  ? state.index
                  : state is TodoEmpty
                      ? state.index
                      : 0;

          void onTodoTap(Todo todo) {
            context.read<TodoBloc>().add(UpdateTodo(todo));
          }

          void onTodoDelete(Todo todo) {
            if (todo.isLocal) {
              // Not possible to delete a local todo
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Cannot delete a local todo!'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black, width: 2))));
              return;
            }

            // show a dialog to confirm the delete
            showGeneralDialog(
              pageBuilder: (context, anim1, anim2) {
                return const SizedBox();
              },
              barrierColor: Colors.black.withOpacity(0.5),
              context: context,
              transitionDuration: const Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: '',
              transitionBuilder: (context, anim1, anim2, child) {
                return Transform.scale(
                  scale: anim1.value,
                  child: AlertDialog(
                    title: const Text('Delete Todo'),
                    content: const Text(
                        'Are you sure you want to delete this todo?'),
                    actions: <Widget>[
                      MaterialButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      MaterialButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          context.pop('delete');
                        },
                      ),
                    ],
                  ),
                );
              },
            ).then((value) => {
                  if (value == 'delete')
                    {context.read<TodoBloc>().add(DeleteTodo(todo))}
                });
          }

          return Scaffold(
              appBar: AppBar(
                title: state is TodoLoaded
                    ? const Text('Todos List', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk'))
                    : state is TodoHistoryLoaded
                        ? const Text('Todo History', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk'))
                        : const Text('Todos List', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<TodoBloc>().add(FetchTodos());
                    },
                  )
                ],
              ),
              body: state is TodoEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (state.index == 0)
                              const Icon(Icons.checklist,
                                  color: Colors.blue, size: 60),
                            if (state.index == 1)
                              const Icon(Icons.celebration_sharp,
                                  color: Colors.purple, size: 60),
                            const SizedBox(
                              height: 20,
                            ),
                            if (state.index == 0)
                              const Text(
                                'Nothing to show here, all todos are completed!',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    letterSpacing: 3),
                                maxLines: 4,
                              ),
                            if (state.index == 1)
                              const Text(
                                'Nothing to show here, nothing found in history!',
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 20,
                                    letterSpacing: 3),
                                maxLines: 4,
                              ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                        children: [
                          CustomSearchBar(onQuery: (query) {
                            context
                                .read<TodoBloc>()
                                .add(SearchTodos(query, currentIndex));
                          }),
                          TodoList(
                            todos: state is TodoLoaded
                                ? state.todos
                                : state is TodoHistoryLoaded
                                    ? state.todos
                                    : [],
                            onTodoTap: onTodoTap,
                            onTodoDelete: onTodoDelete,
                            todoHistory: state is TodoHistoryLoaded,
                          ),
                        ],
                      ),
                  ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  if (index == 0) {
                    context.read<TodoBloc>().add(ShowTodoList());
                  } else {
                    context.read<TodoBloc>().add(ShowTodoHistory());
                  }
                },
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.checklist),
                    label: 'Todos List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.done_all),
                    label: 'History',
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _displayTextInputDialog(context).then((value) {
                    if (value != null) {
                      // validation is here
                      Todo tmpTodo = value;
                      if (tmpTodo.title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Todo title cannot be empty!!'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors.black, width: 2))));
                        return;
                      }
                      context.read<TodoBloc>().add(AddTodo(value));
                    }
                  });
                },
                child: const Icon(Icons.add),
              ));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Please Wait...', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
            centerTitle: true,
          ),
          body: Center(
          child: LoadingAnimationWidget.beat(
            // color: const Color(0xFF1A1A3F),
            color: const Color(0xFFEA3799),
            size: 70,
          )),
        );
      },
    );
  }

  Future<Todo?> _displayTextInputDialog(BuildContext context) async {
    AddtodoCubit addtodoCubit = AddtodoCubit();
    Todo tmpTodo = Todo.empty();
    _todoTitleController.text = tmpTodo.title;
    addtodoCubit.refreshUI(tmpTodo);
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      context: context,
      transitionBuilder: (context, a1, a2, child) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0, curvedValue * 400, 0),
          child: BlocProvider(
            create: (context) => addtodoCubit,
            child: AlertDialog(
              title: const Center(child: Text('Add Todo')),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<AddtodoCubit, AddtodoState>(
                    builder: (context, state) {
                      if (state is AddTodoLoaded) {
                        return Column(
                          children: [
                            TextField(
                              controller: _todoTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                hintText: 'Title',
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                                labelStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.purple,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            //due date
                            Row(
                              children: [
                                const Text("Due Date: "),
                                const SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: tmpTodo.dateAdded,
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                    ).then((value) {
                                      if (value != null) {
                                        tmpTodo.dueDate = value;
                                        addtodoCubit.refreshUI(tmpTodo);
                                      }
                                    });
                                  },
                                  child: Text(DateFormat.yMMMd()
                                      .format(state.todo.dueDate)),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const Center(
                          child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator()));
                    },
                  ),
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                MaterialButton(
                  child: const Text('Create'),
                  onPressed: () {
                    tmpTodo.title = _todoTitleController.text;
                    context.pop(tmpTodo);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
