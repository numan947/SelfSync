import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/common/router.dart';
import 'package:selfsync_frontend/common/ui/custom_search_bar.dart';
import 'package:selfsync_frontend/feature/memories/cubit/add_new_memories_cubit.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';
import 'package:selfsync_frontend/main.dart';

import '../bloc/memories_grid_bloc.dart';
import 'memories_grid_view.dart';

class MemoriesHome extends StatefulWidget {
  const MemoriesHome({super.key});

  @override
  State<MemoriesHome> createState() => _MemoriesHomeState();
}

class _MemoriesHomeState extends State<MemoriesHome> {
  late TextEditingController _memoryTitleController;
  late TextEditingController _memoryDescriptionController;

  late StreamSubscription
      _memoriesSubscription; // for refreshing the memories when they change
  late StreamSubscription _internetConnectionSubscription;

  @override
  void initState() {
    super.initState();
    context.read<MemoriesGridBloc>().add(ShowMemoriesGrid());
    _memoryTitleController = TextEditingController();
    _memoryDescriptionController = TextEditingController();

    _memoriesSubscription = eventBus.on<MemoriesUpdatedEvent>().listen((event) {
      if (mounted) {
        context.read<MemoriesGridBloc>().add(MemoriesUpdated());
      }
    });

    _internetConnectionSubscription =
        eventBus.on<InternetConnectedEvent>().listen((event) {
      if (mounted) {
        context.read<MemoriesGridBloc>().add(SyncMemoriesInternet());
      }
    });
  }

  @override
  void dispose() {
    _memoryTitleController.dispose();
    _memoryDescriptionController.dispose();
    _memoriesSubscription.cancel();
    _internetConnectionSubscription.cancel();
    super.dispose();
  }

  void onMemoriesSelected(MemoriesModel mem) {
    _memoriesSubscription.pause();
    _internetConnectionSubscription.pause();
    goRouter
        .push('/memorieshome/details/', extra: mem.copyWith())
        .then((value) {
      // resume the subscriptions
      _memoriesSubscription.resume();
      _internetConnectionSubscription.resume();
      if (value != null && value is List && value.isNotEmpty) {
        MemoriesModel mm = value[0] as MemoriesModel;
        List<String> deletedImagesKeys = value[1] as List<String>;
        context
            .read<MemoriesGridBloc>()
            .add(UpdateMemory(mm, deletedImagesKeys));
      } else {
        print("Nothing to update!");
      }
    });
  }

  void onDeleteMemory(MemoriesModel mem) {
    // show a dialog to confirm the deletion
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Memory'),
            content: const Text('Are you sure you want to delete this memory?'),
            actions: [
              TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    context.pop('Delete');
                  },
                  child: const Text('Delete'))
            ],
          );
        }).then((value) {
      if (value == 'Delete') {
        // show a snackbar to show that the memory is being deleted
        if (mem.isLocal) {
          // cannot delete a local memory
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cannot delete a local memory'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating),
          );
        } else {
          context.read<MemoriesGridBloc>().add(MemoriesDeleted(mem));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoriesGridBloc, MemoriesGridState>(
      builder: (context, state) {
        if (state is MemoriesGridLoaded) {
          return Scaffold(
              appBar: AppBar(
                  title: const Text('Memories', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context
                            .read<MemoriesGridBloc>()
                            .add(SyncRefreshMemories());
                      },
                    )
                  ]),
              body: Column(
                children: [
                  CustomSearchBar(onQuery: (query) {
                    context.read<MemoriesGridBloc>().add(SearchMemories(query));
                  }),
                  Expanded(
                      child: state.memories.isEmpty
                          ? const Center(
                              child: Text(
                                'Create Memories to see them here!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : MemoriesGridView(
                              memories: state.memories,
                              onMemorySelected: onMemoriesSelected,
                              onDeleteMemory: onDeleteMemory,
                            )),
                ],
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 55),
                child: FloatingActionButton(
                  heroTag: 'addMemory',
                  onPressed: () {
                    // This should be a dialog to add a new memory: just add a title, description and dates
                    _displayAddNewMemoryDialog(context).then((value) {
                      if (value != null) {
                        context
                            .read<MemoriesGridBloc>()
                            .add(CreateNewMemory(value));
                      }
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Please Wait...',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
            centerTitle: true,
          ),
          body: Center(
              child: LoadingAnimationWidget.newtonCradle(
                  color: const Color.fromARGB(255, 255, 65, 98), size: 250)),
        );
      },
    );
  }

  Future<MemoriesModel?> _displayAddNewMemoryDialog(
      BuildContext context) async {
    // the following code should be only executed once
    AddNewMemoriesCubit addNewMemoriesCubit = AddNewMemoriesCubit();
    MemoriesModel tmpMemory = MemoriesModel.empty();
    _memoryTitleController.text = '';
    _memoryDescriptionController.text = '';

    addNewMemoriesCubit.refreshUI(tmpMemory);

    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      context: context,
      transitionBuilder: (context, a1, a2, child) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0, curvedValue * 400, 0),
          child: BlocProvider(
            create: (context) => addNewMemoriesCubit,
            child: AlertDialog(
              title: const Center(child: Text('A New Memory!')),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<AddNewMemoriesCubit, AddNewMemoriesState>(
                    builder: (context, state) {
                      if (state is AddNewMemoriesLoaded) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              controller: _memoryTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                hintText: 'Title',
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                                labelStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.purple,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            const SizedBox(height: 10),
                            //description
                            TextField(
                              maxLines: 20,
                              minLines: 3,
                              controller: _memoryDescriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Description',
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                                labelStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.purple,
                                    decoration: TextDecoration.none),
                              ),
                            ),

                            const SizedBox(height: 10),

                            //dates
                            const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Start Date"),
                                  SizedBox(width: 10),
                                  Text("End Date"),
                                ]),
                            const SizedBox(height: 5),
                            //dates
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        // show date picker
                                        showDatePicker(
                                          context: context,
                                          initialDate:
                                              state.memoriesModel.startDate ??
                                                  DateTime.now(),
                                          firstDate: DateTime(1980),
                                          lastDate: DateTime(2100),
                                        ).then((value) {
                                          if (value != null) {
                                            tmpMemory = tmpMemory.copyWith(
                                                startDate: value);
                                            addNewMemoriesCubit.refreshUI(state
                                                .memoriesModel
                                                .copyWith(startDate: value));
                                          }
                                        });
                                      },
                                      child: Text(state
                                                  .memoriesModel.startDate ==
                                              null
                                          ? 'Select'
                                          : DateFormat('yyyy-MM-dd').format(
                                              state.memoriesModel.startDate!))),
                                  const SizedBox(width: 10),
                                  TextButton(
                                      onPressed: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate:
                                              state.memoriesModel.startDate ??
                                                  DateTime.now(),
                                          firstDate: DateTime(1980),
                                          lastDate: DateTime(2100),
                                        ).then((value) {
                                          if (value != null) {
                                            tmpMemory = tmpMemory.copyWith(
                                                endDate: value);
                                            addNewMemoriesCubit.refreshUI(state
                                                .memoriesModel
                                                .copyWith(endDate: value));
                                          }
                                        });
                                      },
                                      child: Text(state.memoriesModel.endDate ==
                                              null
                                          ? 'Select'
                                          : DateFormat('yyyy-MM-dd').format(
                                              state.memoriesModel.endDate!))),
                                ])
                          ],
                        );
                      }
                      return const Center(
                          child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator()));
                    },
                  ),
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                MaterialButton(
                  child: const Text('Create'),
                  onPressed: () {
                    tmpMemory = tmpMemory.copyWith(
                        title: _memoryTitleController.text,
                        description: _memoryDescriptionController.text);
                    context.pop(tmpMemory);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
