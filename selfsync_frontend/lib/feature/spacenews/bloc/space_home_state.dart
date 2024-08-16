part of 'space_home_bloc.dart';

@immutable
sealed class SpaceHomeState extends Equatable {}

final class SpaceHomeLoading extends SpaceHomeState {
  @override
  List<Object> get props => [];
}

final class SpaceHomeLoaded extends SpaceHomeState {
  final List<SpaceNewsModel> results;
  final int selectedIndex;
  final int newsItemCount;
  SpaceHomeLoaded(this.results, this.selectedIndex, this.newsItemCount);
  @override
  List<Object> get props => [];
}