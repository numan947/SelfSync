part of 'add_note_view_cubit.dart';

@immutable
sealed class AddNoteViewCubitState extends Equatable{}

final class AddViewCubitLoading extends AddNoteViewCubitState {
  @override
  List<Object> get props => [];
}

final class AddNoteViewLoaded extends AddNoteViewCubitState {
  final NoteItem note;

  AddNoteViewLoaded(this.note);

  @override
  List<Object> get props => [note];
}
