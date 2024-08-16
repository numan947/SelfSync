import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';
import 'package:selfsync_frontend/feature/notes/ui/note_add_view.dart';

class NoteEditView extends StatelessWidget {
  final NoteItem note;

  const NoteEditView({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return NoteAddOrEdit(
        note: note,
        editable: true,
        onSave: (lst) {
          NoteItem nt = lst[0] as NoteItem;
          List<String> deletedImages = lst[1] as List<String>;
          GoRouter.of(context).pop([nt, deletedImages]);
        },
        onCancel: () {
          GoRouter.of(context).pop();
        });
  }
}
