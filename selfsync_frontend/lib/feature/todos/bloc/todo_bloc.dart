// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/feature/todos/data/todo_repository.dart';
import 'package:selfsync_frontend/feature/todos/model/todo_model.dart';
import 'package:selfsync_frontend/main.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<Todo> todos = [];
  TodoRepository todoRepository;

  @override
  String toString() =>
      'TodoBloc(todos: $todos, todoRepository: $todoRepository)';

  TodoBloc(
    this.todoRepository,
  ) : super(TodoLoading()) {
    on<FetchTodos>(_onFetchTodos);
    on<ShowTodoList>(_onShowTodoList);
    on<ShowTodoHistory>(_onShowTodoHistory);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<TodosSynced>(_onTodosSynced);
    on<TodoListInternetConnected>(_onInternetConnected);
    on<SearchTodos>(_onSearchTodos);
  }

  Future<FutureOr<void>> _onFetchTodos(
      FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    todos = await todoRepository.fetchTodos();
    //sort the todos by the due date
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    //filter out the completed todos
    List<Todo> tmpTodos = todos.where((element) => !element.completed).toList();
    try {
      if (todos.isEmpty) {
        emit(TodoEmpty(0));
      } else {
        emit(TodoLoaded(tmpTodos, 0));
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  FutureOr<void> _onShowTodoList(
      ShowTodoList event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    if (todos.isEmpty) {
      todos = await todoRepository.fetchTodos(); // network call will be here
    }
    else{
      todos = todoRepository.getTodos;
    }

    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    try {
      //filter out the completed todos
      var showTodos = todos.where((element) => !element.completed).toList();
      if (showTodos.isEmpty) {
        emit(TodoEmpty(0));
      } else {
        emit(TodoLoaded(showTodos, 0));
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  FutureOr<void> _onShowTodoHistory(
      ShowTodoHistory event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    if (todos.isEmpty) {
      todos = await todoRepository.fetchTodos(); // network call will be here
    }else{
      todos = todoRepository.getTodos;
    }
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    try {
      //filter out the completed todos
      var showTodos = todos.where((element) => element.completed).toList();
      if (showTodos.isEmpty) {
        emit(TodoEmpty(1));
      } else {
        emit(TodoHistoryLoaded(showTodos, 1));
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  FutureOr<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    await todoRepository.addTodo(event.todo); // network call will be here
    todos = todoRepository.getTodos; // get the todos from the repository
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    // filter out the completed todos
    List<Todo> tmpTodos = todos.where((element) => !element.completed).toList();
    try {
      if (tmpTodos.isEmpty) {
        emit(TodoEmpty(0));
      } else {
        emit(TodoLoaded(tmpTodos, 0));
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateTodo(
      UpdateTodo event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    bool showHistory = event.todo.completed;
    // update the todo
    event.todo.completed = !event.todo.completed;
    await todoRepository.updateTodo(event.todo); // network call will be here
    todos = todoRepository.getTodos; // get the todos from the repository
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    try {
      if (showHistory) {
        var showTodos = todos.where((element) => element.completed).toList();
        if (showTodos.isEmpty) {
          emit(TodoEmpty(1));
        } else {
          emit(TodoHistoryLoaded(showTodos, 1));
        }
      } else {
        var showTodos = todos.where((element) => !element.completed).toList();
        if (showTodos.isEmpty) {
          emit(TodoEmpty(0));
        } else {
          emit(TodoLoaded(showTodos, 0));
        }
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  FutureOr<void> _onDeleteTodo(
      DeleteTodo event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    bool showHistory = event.todo.completed;
    await todoRepository.deleteTodo(event.todo); // network call will be here
    todos = todoRepository.getTodos; // get the todos from the repository
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    try {
      if (showHistory) {
        var showTodos = todos.where((element) => element.completed).toList();
        if (showTodos.isEmpty) {
          emit(TodoEmpty(1));
        } else {
          emit(TodoHistoryLoaded(showTodos, 1));
        }
      } else {
        var showTodos = todos.where((element) => !element.completed).toList();
        if (showTodos.isEmpty) {
          emit(TodoEmpty(0));
        } else {
          emit(TodoLoaded(showTodos, 0));
        }
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  FutureOr<void> _onTodosSynced(TodosSynced event, Emitter<TodoState> emit) {
    todos = todoRepository.getTodos; // get the todos from the repository
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (event.currentIndex == 0) {
      List<Todo> showTodos =
          todos.where((element) => !element.completed).toList();
      if (showTodos.isEmpty) {
        emit(TodoEmpty(0));
      } else {
        emit(TodoLoading());
        emit(TodoLoaded(showTodos, 0));
      }
    } else {
      List<Todo> showTodos =
          todos.where((element) => element.completed).toList();
      if (showTodos.isEmpty) {
        emit(TodoEmpty(1));
      } else {
        emit(TodoLoading());
        emit(TodoHistoryLoaded(showTodos, 1));
      }
    }
  }

  FutureOr<void> _onInternetConnected(
      TodoListInternetConnected event, Emitter<TodoState> emit) {
    todoRepository.syncDeletedTodos().then((value) => {
          todoRepository.syncTodos().then((value) => {
                if (value) {eventBus.fire(TodosUpdatedEvent())}
              })
        });
  }

  FutureOr<void> _onSearchTodos(SearchTodos event, Emitter<TodoState> emit) {
    bool history = event.currentIndex == 1;
    todos = todoRepository.getTodos;
    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    List<Todo> showTodos = todos
        .where((element) => element.completed == history && element.title.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
    if (history){
      emit(TodoHistoryLoaded(showTodos, 1));
    }
    else{
      emit(TodoLoaded(showTodos, 0));
    }
  }
}
