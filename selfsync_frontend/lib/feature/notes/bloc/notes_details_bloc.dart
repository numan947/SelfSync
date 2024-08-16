import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/feature/notes/data/notes_repository.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';

import '../../../common/common_functions.dart';
import '../../../common/service/storage_service.dart';
import '../../../main.dart';

part 'notes_details_event.dart';
part 'notes_details_state.dart';

class NotesDetailsBloc extends Bloc<NotesDetailsEvent, NotesDetailsState> {
  static const String moduleName = 'notes';
  NoteItem note;
  final NotesRepository _notesRepository;
  final StorageService storageService = StorageService();
  NotesDetailsBloc(this.note, this._notesRepository)
      : super(NotesDetailsLoading()) {
    on<NotesDetailsFetch>(_onFetch);
    on<NotesDetailsEdit>(_onEdit);
    on<NoteDetailsSoftRefresh>(_onSoftRefresh);
    on<NotesDetailsSave>(_onSave);
  }

  FutureOr<void> _onFetch(
      NotesDetailsFetch event, Emitter<NotesDetailsState> emit) async {
    emit(NotesDetailsLoading());
    final List<NoteItem> notes = _notesRepository.getNotes;
    note = notes.firstWhere((element) => element.id == note.id);
    final List<String> keysToDownload = note.imageKeysToUrls.keys
        .toList()
        .where((element) =>
            note.imageKeysToUrls[element] != null &&
            !isLocalPath(note.imageKeysToUrls[element]!))
        .toList();
    // print(keysToDownload);
    if (keysToDownload.isNotEmpty) {
      storageService
          .createMultipleDownloadLinks(keysToDownload, "$moduleName/${note.id}")
          .then((value) {
        note.imageKeysToUrls.addAll(value);
        eventBus.fire(NoteDetailsImageLoadedEvent());
      });
    }
    emit(NotesDetailsShowing(note));
  }

  FutureOr<void> _onEdit(
      NotesDetailsEdit event, Emitter<NotesDetailsState> emit) {
    emit(NotesDetailsLoading());
    emit(NotesDetailsEditing(note));
  }

  FutureOr<void> _onSoftRefresh(
      NoteDetailsSoftRefresh event, Emitter<NotesDetailsState> emit) {
    emit(NotesDetailsLoading());
    emit(NotesDetailsShowing(note));
  }

  Future<FutureOr<void>> _onSave(
      NotesDetailsSave event, Emitter<NotesDetailsState> emit) async {
    emit(NotesDetailsLoading());
    await _notesRepository.deleteImages(event.deletedImages);
    await _notesRepository.updateNote(event.note);
    note = event.note;
    emit(NotesDetailsShowing(note));
  }
}
