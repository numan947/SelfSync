part of 'todo_bloc.dart';

@immutable
sealed class TodoState extends Equatable {}

final class TodoLoading extends TodoState {
  @override
  List<Object?> get props => [];
}

final class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final int index;

  TodoLoaded(this.todos, this.index);

  @override
  List<Object?> get props => [todos, index];
}

final class TodoHistoryLoaded extends TodoState {
  final List<Todo> todos;
  final int index;

  TodoHistoryLoaded(this.todos, this.index);

  @override
  List<Object?> get props => [todos, index];
}

final class TodoError extends TodoState {
  final String message;

  TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

final class TodoAdded extends TodoState {
  final Todo todo;

  TodoAdded(this.todo);

  @override
  List<Object?> get props => [todo];
}

final class TodoDeleted extends TodoState {
  final Todo todo;

  TodoDeleted(this.todo);

  @override
  List<Object?> get props => [todo];
}


final class TodoEmpty extends TodoState {
  final int index;
  TodoEmpty(this.index);
  @override
  List<Object?> get props => [];
}


