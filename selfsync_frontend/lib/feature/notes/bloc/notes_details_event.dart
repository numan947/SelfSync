part of 'notes_details_bloc.dart';

@immutable
sealed class NotesDetailsEvent extends Equatable{}

final class NotesDetailsFetch extends NotesDetailsEvent {
  @override
  List<Object?> get props => [];
}
final class NotesDetailsEdit extends NotesDetailsEvent {
  @override
  List<Object?> get props => [];
}
final class NotesDetailsSave extends NotesDetailsEvent {
  final NoteItem note;
  final List<String> deletedImages;
  NotesDetailsSave(this.note, this.deletedImages);
  @override
  List<Object?> get props => [note, deletedImages];
}
final class NoteDetailsSoftRefresh extends NotesDetailsEvent {
  @override
  List<Object?> get props => [];
}
final class NoteDetailsInternetConnected extends NotesDetailsEvent {
  @override
  List<Object?> get props => [];
}