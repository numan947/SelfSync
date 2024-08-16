part of 'addtodo_cubit.dart';

@immutable
sealed class AddtodoState extends Equatable {}

final class AddTodoInitial extends AddtodoState {
  @override
  List<Object?> get props => [];
}

final class AddTodoLoaded extends AddtodoState {
  final Todo todo;
  AddTodoLoaded(this.todo);
  @override
  List<Object?> get props => [todo];
}
