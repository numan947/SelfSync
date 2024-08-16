part of 'notes_details_bloc.dart';

@immutable
sealed class NotesDetailsState extends Equatable {}

final class NotesDetailsLoading extends NotesDetailsState {
  @override
  List<Object?> get props => [];
}

final class NotesDetailsShowing extends NotesDetailsState {
  final NoteItem note;
  NotesDetailsShowing(this.note);

  @override
  List<Object?> get props => [note];
}

final class NotesDetailsEditing extends NotesDetailsState {
  final NoteItem note;
  NotesDetailsEditing(this.note);
  @override
  List<Object?> get props => [note];
}

final class NotesDetailsError extends NotesDetailsState {
  final String message;
  NotesDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

final class NotesDetailsDeleted extends NotesDetailsState {
  @override
  List<Object?> get props => [];
}
