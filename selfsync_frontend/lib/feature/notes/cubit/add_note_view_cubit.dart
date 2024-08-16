import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';

part 'add_note_view_cubit_state.dart';

class AddNoteViewCubit extends Cubit<AddNoteViewCubitState> {
  AddNoteViewCubit() : super(AddViewCubitLoading());

  void refreshUI(NoteItem note) {
    emit(AddViewCubitLoading());
    emit(AddNoteViewLoaded(note));
  }
}
