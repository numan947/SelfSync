import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';

@immutable
sealed class NotesListState extends Equatable {}

class ShowNotesAddView extends NotesListState {
  @override
  List<Object?> get props => [];
} // Add state

class NotesListLoading extends NotesListState {
  @override
  List<Object?> get props => [];
} // Loading state

class NotesListLoaded extends NotesListState {
  final List<NoteItem> notes; // only loaded state has notes
  NotesListLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
} // Loaded state

class NotesListError extends NotesListState {
  @override
  List<Object?> get props => [];
} // Error state

class NotesListEmpty extends NotesListState {
  @override
  List<Object?> get props => [];
} // Empty state

