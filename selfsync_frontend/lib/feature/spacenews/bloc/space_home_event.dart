part of 'space_home_bloc.dart';

@immutable
sealed class SpaceHomeEvent extends Equatable {}

final class LoadArticlesEvent extends SpaceHomeEvent {
  final int newsItemCount;
  LoadArticlesEvent(this.newsItemCount);

  @override
  List<Object> get props => [];
}

final class LoadBlogsEvent extends SpaceHomeEvent {
  final int newsItemCount;
  LoadBlogsEvent(this.newsItemCount);

  @override
  List<Object> get props => [];
}

final class LoadReportsEvent extends SpaceHomeEvent {
  final int newsItemCount;
  LoadReportsEvent(this.newsItemCount);

  @override
  List<Object> get props => [];
}
