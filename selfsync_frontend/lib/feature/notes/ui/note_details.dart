import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/feature/notes/bloc/notes_details_bloc.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';
import 'package:selfsync_frontend/feature/notes/ui/note_show_view.dart';
import 'package:selfsync_frontend/main.dart';

class NoteDetailsView extends StatefulWidget {
  const NoteDetailsView({super.key});

  @override
  State<NoteDetailsView> createState() => _NoteDetailsViewState();
}

class _NoteDetailsViewState extends State<NoteDetailsView> {
  StreamSubscription? _subscription;
  StreamSubscription? _internetSubscription;
  StreamSubscription? _noteupdateSubscription;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotesDetailsBloc>(context).add(NotesDetailsFetch());
    _noteupdateSubscription = eventBus.on<NotesUpdatedEvent>().listen((event) {
      if (mounted) {
        BlocProvider.of<NotesDetailsBloc>(context).add(NotesDetailsFetch());
      }
    });
    _subscription = eventBus.on<NoteDetailsImageLoadedEvent>().listen((event) {
      if (mounted) {
        BlocProvider.of<NotesDetailsBloc>(context).add(NoteDetailsSoftRefresh());
      }
    });
    _internetSubscription = eventBus.on<InternetConnectedEvent>().listen((event) {
      if (mounted) {
        BlocProvider.of<NotesDetailsBloc>(context).add(NotesDetailsFetch());
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _internetSubscription?.cancel();
    _noteupdateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesDetailsBloc, NotesDetailsState>(
      builder: (context, state) {
        if (state is NotesDetailsLoading) {
          return Center(
              child: LoadingAnimationWidget.twistingDots(
            leftDotColor: const Color(0xFF1A1A3F),
            rightDotColor: const Color(0xFFEA3799),
            size: 200,
          ));
        }
        if (state is NotesDetailsShowing) {
          // get the note from the bloc
          final note = state.note;
          return PopScope(
            onPopInvoked: (didpop) {
              if (didpop) {
                GoRouter.of(context).pop();
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('Note Details', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: note.localOnly
                              ? Colors.grey
                              : Colors.blueAccent[400]),
                      onPressed: () {
                        if (!note.localOnly) {
                          BlocProvider.of<NotesDetailsBloc>(context)
                              .add(NotesDetailsEdit());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('You can edit after note is uploaded!'),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: note.localOnly
                              ? Colors.grey
                              : Colors.redAccent[400]),
                      onPressed: () {
                        if (note.localOnly) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'You can delete after note is uploaded!'),
                            ),
                          );
                          return;
                        }
                        // show a dialog to confirm the delete
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Note'),
                              content: const Text(
                                  'Are you sure you want to delete this note?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('Yes');
                                  },
                                  child: const Text('Yes'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('No');
                                  },
                                  child: const Text('No'),
                                ),
                              ],
                            );
                          },
                        ).then((value) => {
                              if (value == 'Yes')
                                {
                                  GoRouter.of(context).pop('delete'),
                                }
                            });
                      },
                    ),
                  ],
                ),
                body: NoteShowView(note: note)),
          );
        }

        if (state is NotesDetailsEditing) {
          return const Center(
            child: Text('Edit Note'),
          );
        }

        if (state is NotesDetailsDeleted) {
          //add a delay and then pop the screen
          return Center(
              child: LoadingAnimationWidget.newtonCradle(
                  color: const Color(0xFFEA3799), size: 60));
        }

        if (state is NotesDetailsError) {
          return Center(
            child: Text(state.message),
          );
        }
        return const Center(
          child: Text('Unknown state'),
        );
      },
      listener: (BuildContext context, NotesDetailsState state) {
        if (state is NotesDetailsEditing) {
          GoRouter.of(context)
              .push('/noteshome/details/edit', extra: state.note)
              .then((value){
            if (value != null) {
              value = value as List;
              final NoteItem v = value[0] as NoteItem;
              final List<String> deletedImages = value[1] as List<String>;
              BlocProvider.of<NotesDetailsBloc>(context)
                  .add(NotesDetailsSave(v, deletedImages));
            } else {
              BlocProvider.of<NotesDetailsBloc>(context)
                  .add(NoteDetailsSoftRefresh());
            }
          });
        }
        if (state is NotesDetailsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          BlocProvider.of<NotesDetailsBloc>(context).add(NotesDetailsFetch());
        }
      },
    );
  }
}
