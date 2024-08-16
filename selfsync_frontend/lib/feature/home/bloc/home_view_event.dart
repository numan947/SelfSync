part of 'home_view_bloc.dart';

@immutable
sealed class HomeViewEvent extends Equatable{}

final class LoadHomeViewData extends HomeViewEvent {
  @override
  List<Object> get props => [];
}
