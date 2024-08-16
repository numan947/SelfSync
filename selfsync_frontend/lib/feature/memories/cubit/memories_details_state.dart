part of 'memories_details_cubit.dart';

@immutable
sealed class MemoriesDetailsState {}

final class MemoriesDetailsLoading extends MemoriesDetailsState {}

final class MemoriesDetailsLoaded extends MemoriesDetailsState {
  final MemoriesModel memory;
  MemoriesDetailsLoaded(this.memory);
}