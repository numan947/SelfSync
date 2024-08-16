part of 'slide_show_cubit.dart';

@immutable
sealed class SlideShowState {}

final class SlideShowLoading extends SlideShowState {}

final class SlideShowLoaded extends SlideShowState {
  final int currentIndex;
  SlideShowLoaded(this.currentIndex);
}