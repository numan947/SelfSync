part of 'add_new_memories_cubit.dart';

@immutable
sealed class AddNewMemoriesState extends Equatable{}

final class AddNewMemoriesLoading extends AddNewMemoriesState {
  @override
  List<Object> get props => [];
}

final class AddNewMemoriesLoaded extends AddNewMemoriesState {
  final MemoriesModel memoriesModel;
  AddNewMemoriesLoaded(this.memoriesModel);

  @override
  List<Object> get props => [memoriesModel];
}