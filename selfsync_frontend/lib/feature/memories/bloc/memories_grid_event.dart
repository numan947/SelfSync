part of 'memories_grid_bloc.dart';

@immutable
sealed class MemoriesGridEvent extends Equatable {}

final class ShowMemoriesGrid extends MemoriesGridEvent {
  @override
  List<Object> get props => [];
}

final class CreateNewMemory extends MemoriesGridEvent {
  final MemoriesModel memory;
  CreateNewMemory(this.memory);
  @override
  List<Object> get props => [memory];
}

final class MemoriesUpdated extends MemoriesGridEvent { // this event is fired when the memories are updated, i.e. upload complete
  MemoriesUpdated();
  @override
  List<Object> get props => [];
}

final class MemoriesDeleted extends MemoriesGridEvent {
  final MemoriesModel memory;
  MemoriesDeleted(this.memory);
  @override
  List<Object> get props => [memory];
}

final class UpdateMemory extends MemoriesGridEvent { // this event is fired when the memory is updated, i.e. edit complete
  final MemoriesModel memory;
  final List<String> deletedImagesKeys;
  UpdateMemory(this.memory, this.deletedImagesKeys);
  @override
  List<Object> get props => [memory];
}

final class SyncRefreshMemories extends MemoriesGridEvent {
  @override
  List<Object> get props => [];
}

final class SyncMemoriesInternet extends MemoriesGridEvent {
  @override
  List<Object> get props => [];
}

final class SearchMemories extends MemoriesGridEvent {
  final String query;
  SearchMemories(this.query);
  @override
  List<Object> get props => [query];
}