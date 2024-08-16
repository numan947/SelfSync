part of 'home_view_bloc.dart';

@immutable
sealed class HomeViewState extends Equatable{}

final class HomeViewDataLoading extends HomeViewState {
  @override
  List<Object> get props => [];
}

final class HomeViewDataLoaded extends HomeViewState {
  final HomeModel homeData;
  HomeViewDataLoaded(this.homeData);
  @override
  List<Object> get props => [homeData];
}

