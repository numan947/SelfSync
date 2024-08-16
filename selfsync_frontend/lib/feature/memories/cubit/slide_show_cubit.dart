import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'slide_show_state.dart';

class SlideShowCubit extends Cubit<SlideShowState> {
  SlideShowCubit() : super(SlideShowLoading());

  void refreshUI(int currentIndex) {
    emit(SlideShowLoading());
    emit(SlideShowLoaded(currentIndex));
  }
}
