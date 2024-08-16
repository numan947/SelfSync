part of 'todo_bloc.dart';

@immutable
sealed class TodoEvent extends Equatable {}

final class FetchTodos extends TodoEvent {
  FetchTodos();
  
  @override
  List<Object?> get props => [];
}

final class AddTodo extends TodoEvent {
  final Todo todo;

  AddTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

final class DeleteTodo extends TodoEvent {
  final Todo todo;

  DeleteTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

final class UpdateTodo extends TodoEvent {
  final Todo todo;

  UpdateTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

final class ShowTodoHistory extends TodoEvent {
  ShowTodoHistory();
  
  @override
  List<Object?> get props => [];
}

final class ShowTodoList extends TodoEvent {
  ShowTodoList();
  
  @override
  List<Object?> get props => [];
}


final class TodosSynced extends TodoEvent {
  final int currentIndex;
  TodosSynced(this.currentIndex);
  @override
  List<Object?> get props => [];
}

final class TodoListInternetConnected extends TodoEvent {
  final int currentIndex;
  TodoListInternetConnected(this.currentIndex);
  @override
  List<Object?> get props => [];
}

final class SearchTodos extends TodoEvent {
  final String query;
  final int currentIndex;
  SearchTodos(this.query, this.currentIndex);
  @override
  List<Object?> get props => [];
}