import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/common/router.dart';
import 'package:selfsync_frontend/common/ui/custom_search_bar.dart';
import 'package:selfsync_frontend/feature/notes/bloc/import_notes_list_bloc.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';
import 'package:selfsync_frontend/feature/notes/ui/note_add_view.dart';
import 'package:selfsync_frontend/feature/notes/ui/notes_list_item.dart';
import 'package:selfsync_frontend/main.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});
  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  NoteItem? newNote;
  late StreamSubscription? _subscription;
  late StreamSubscription? _internetSubscription;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotesListBloc>(context).add(NotesListFetch());
    _subscription = eventBus.on<NotesUpdatedEvent>().listen(
      (event) {
        if (mounted) {
          BlocProvider.of<NotesListBloc>(context).add(NotesListSyncComplete());
        }
      },
    );
    _internetSubscription =
        eventBus.on<InternetConnectedEvent>().listen((event) {
          if (mounted) {
            BlocProvider.of<NotesListBloc>(context).add(NoteListInternetConnected());
          }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _internetSubscription?.cancel();
  }

  void onNoteSaved(List<dynamic>lst) {
    final note = lst[0] as NoteItem;
    final List<String>deletedImages = lst[1] as List<String>;
    // validate the note
    if (note.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    else{
      BlocProvider.of<NotesListBloc>(context).add(NotesListSave(note));
    }
  }
  void onNoteCancelled() {
    BlocProvider.of<NotesListBloc>(context).add(NotesListBackFromDetails());
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesListBloc, NotesListState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: state is ShowNotesAddView
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // go back to the notes list, this will cancel the new note creation
                      BlocProvider.of<NotesListBloc>(context)
                          .add(NotesListBackFromDetails());
                    },
                  )
                : null,
            title: const Center(child: Text('Notes', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),),
            actions: <Widget>[
              if (state is! NotesListLoading && state is! ShowNotesAddView)
                Tooltip(
                  message: 'Refresh notes',
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      BlocProvider.of<NotesListBloc>(context)
                          .add(NotesListRefresh());
                    },
                  ),
                ),
            ],
          ),
          body: BlocConsumer<NotesListBloc, NotesListState>(
            builder: (context, state) {
              if (state is NotesListLoading) {
                return Center(
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                  size: 200, color: const Color(0xFFEA3799),
                ));
              } else if (state is NotesListLoaded || state is NotesListEmpty) {
                // Listview with notes
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CustomSearchBar(onQuery: (query) {
                        BlocProvider.of<NotesListBloc>(context).add(
                            NotesListSearch(query)); // search notes by title
                      }),
                      if (state is NotesListEmpty)
                        const Center(
                          child: Text('No notes found'),
                        ),
                      if (state is NotesListLoaded)
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return NotesListItem(
                                  note: state.notes[index],
                                  onTap: () {
                                    // print("State: $state from listener");
                                    _subscription?.pause();
                                    _internetSubscription?.pause();
                                    goRouter
                                        .push('/noteshome/details/',
                                            extra: state.notes[index])
                                        .then((value) {
                                      _subscription?.resume();
                                      _internetSubscription?.resume();
                                      // update the notes list
                                      if (value == 'delete') {
                                        BlocProvider.of<NotesListBloc>(context)
                                            .add(NotesListDelete(
                                                state.notes[index]));
                                      } else {
                                        BlocProvider.of<NotesListBloc>(context)
                                            .add(NotesListBackFromDetails());
                                      }
                                    });
                                  },
                                  onDelete: () {
                                    // show dialog to confirm delete
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Note'),
                                          content: const Text(
                                              'Are you sure you want to delete this note?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop('No');
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop('Yes');
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    ).then((value) => {
                                          if (value == 'Yes')
                                            {
                                              // delete the note
                                              BlocProvider.of<NotesListBloc>(
                                                      context)
                                                  .add(NotesListDelete(
                                                      state.notes[index]))
                                            }
                                        });
                                  });
                            },
                            itemCount: state.notes.length,
                          ),
                        ),
                    ],
                  ),
                );
              } else if (state is ShowNotesAddView) {
                newNote = NoteItem.empty(); // create a new note
                return NoteAddOrEdit(
                  note:
                      newNote!, // pass the new note to the NoteView to be edited
                  editable: true,
                  onSave: onNoteSaved,
                  onCancel: onNoteCancelled,
                );
              } else if (state is NotesListError) {
                return const Center(
                  child: Text('Error loading notes'),
                );
              } else {
                return const Center(
                  child: Text('Unknown state'),
                );
              }
            },
            listener: (BuildContext context, NotesListState state) {},
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (state is! NotesListLoading && state is! ShowNotesAddView)
                Tooltip(
                  message: 'Add new note',
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 55),
                    child: FloatingActionButton(
                      heroTag: 'AddNoteButton',
                      onPressed: () {
                        BlocProvider.of<NotesListBloc>(context)
                            .add(NotesListAdd());
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
