import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/todo_model.dart';

part 'addtodo_state.dart';

class AddtodoCubit extends Cubit<AddtodoState> {
  AddtodoCubit() : super(AddTodoInitial());

  void refreshUI(Todo todo) {
    print ('AddtodoCubit: refreshUI');
    emit(AddTodoInitial());
    emit(AddTodoLoaded(todo));
  }
}
