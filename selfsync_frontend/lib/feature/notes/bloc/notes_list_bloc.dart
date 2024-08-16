import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/feature/notes/bloc/import_notes_list_bloc.dart';
import 'package:selfsync_frontend/feature/notes/data/notes_repository.dart';
import 'package:selfsync_frontend/main.dart';

import '../../../common/eventbus_events.dart';
import '../model/notes_model.dart';

class NotesListBloc extends Bloc<NotesListEvent, NotesListState>{
  final NotesRepository _notesRepository;

  NotesListBloc(this._notesRepository):super(NotesListLoading())
  {
    on<NotesListFetch>(_handleNotesFetch);
    on<NotesListAdd>(_handleNotesAdd);
    on<NotesListSave>(_handleNotesSave);
    on<NotesListDelete>(_handleNotesDelete);
    on<NotesListSearch>(_handleNotesSearch);
    on<NotesListSyncComplete>(_handleNotesSyncComplete);
    on<NotesListBackFromDetails>((event, emit) {
      emit(NotesListLoading());
      if(_notesRepository.notes.isEmpty){
        emit(NotesListEmpty());
      }
      else{
        emit(NotesListLoaded(_notesRepository.getNotes));
      }
    });
    on<NotesListRefresh>(_handleNoteRefresh);
    on<NoteListInternetConnected>((event, emit) {
      _notesRepository.syncNotes().then((value) {
        if(value){
          print('Internet connected, notes synced');
          eventBus.fire(NotesUpdatedEvent());
        }
      });
    });
  }


  Future<FutureOr<void>> _handleNotesFetch(NotesListFetch event, Emitter<NotesListState> emit) async {
    emit(NotesListLoading());
    List<NoteItem>notes = await _notesRepository.fetchNotes();
    if(notes.isEmpty){
      emit(NotesListEmpty());
    }
    else{
      emit(NotesListLoaded(notes));
    }
  }

  FutureOr<void> _handleNotesAdd(NotesListAdd event, Emitter<NotesListState> emit) {
    emit(ShowNotesAddView());
  }

  Future<FutureOr<void>> _handleNotesSave(NotesListSave event, Emitter<NotesListState> emit) async {
    emit(NotesListLoading());
    await _notesRepository.addNote(event.note);
    List<NoteItem>notes = _notesRepository.getNotes;
    if (_notesRepository.notes.isEmpty){
      emit(NotesListEmpty());
    }
    else {
      emit(NotesListLoaded(notes));
    }
  }

  Future<FutureOr<void>> _handleNotesDelete(NotesListDelete event, Emitter<NotesListState> emit) async {
    emit(NotesListLoading());
    await _notesRepository.deleteNote(event.note);
    if (_notesRepository.notes.isEmpty){
      emit(NotesListEmpty());
    }
    else {
      emit(NotesListLoaded(_notesRepository.notes));
    }
  }

  FutureOr<void> _handleNotesSearch(NotesListSearch event, Emitter<NotesListState> emit) {
    List<NoteItem>notes = _notesRepository.getNotes;
    notes = notes.where((element) => element.title.toLowerCase().contains(event.query.toLowerCase())).toList();
    if(notes.isEmpty){
      emit(NotesListEmpty());
    }
    else{
      emit(NotesListLoaded(notes));
    }
  }

  FutureOr<void> _handleNotesSyncComplete(NotesListSyncComplete event, Emitter<NotesListState> emit) async{
    emit(NotesListLoading());
    emit(NotesListLoaded(_notesRepository.getNotes));
  }

  Future<FutureOr<void>> _handleNoteRefresh(NotesListRefresh event, Emitter<NotesListState> emit) async {
    emit(NotesListLoading());
    List<NoteItem> notes = await _notesRepository.fetchNotes();
    if(notes.isEmpty){
      emit(NotesListEmpty());
    }
    else{
      emit(NotesListLoaded(notes));
    }
  }
}