
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../model/memories_model.dart';

part 'add_new_memories_state.dart';

class AddNewMemoriesCubit extends Cubit<AddNewMemoriesState> {
  AddNewMemoriesCubit() : super(AddNewMemoriesLoading());

  void refreshUI(MemoriesModel mem) {
    emit(AddNewMemoriesLoading());
    emit(AddNewMemoriesLoaded(mem));
  }
}
