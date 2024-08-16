import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';

@immutable
sealed class NotesListEvent extends Equatable{}

class NotesListFetch extends NotesListEvent {
  @override
  List<Object?> get props => [];
}

class NotesListRefresh extends NotesListEvent {
  @override
  List<Object?> get props => [];
}

class NotesListDelete extends NotesListEvent {
  final NoteItem note;
  NotesListDelete(this.note);

  @override
  List<Object?> get props => [note];
}

class NotesListAdd extends NotesListEvent {
  NotesListAdd();
  @override
  List<Object?> get props => [];
}


class NotesListSave extends NotesListEvent {
  final NoteItem note;
  NotesListSave(this.note);

  @override
  List<Object?> get props => [note];
}

class NotesListSearch extends NotesListEvent {
  final String query;
  NotesListSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class NotesListBackFromDetails extends NotesListEvent {
  @override
  List<Object?> get props => [];
}

class NotesListSyncComplete extends NotesListEvent {
  @override
  List<Object?> get props => [];
}

class NoteListInternetConnected extends NotesListEvent {
  @override
  List<Object?> get props => [];
}