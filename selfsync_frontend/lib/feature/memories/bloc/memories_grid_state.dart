part of 'memories_grid_bloc.dart';

@immutable
sealed class MemoriesGridState extends Equatable {}

final class MemoriesGridLoading extends MemoriesGridState {
  @override
  List<Object> get props => [];
}

final class MemoriesGridLoaded extends MemoriesGridState {
  final List<MemoriesModel> memories;

  MemoriesGridLoaded(this.memories);

  @override
  List<Object> get props => [memories];
}

final class MemoriesGridError extends MemoriesGridState {
  final String message;

  MemoriesGridError(this.message);

  @override
  List<Object> get props => [message];
}
