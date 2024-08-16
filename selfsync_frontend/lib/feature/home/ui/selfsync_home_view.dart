import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../bloc/home_view_bloc.dart';

class SelfSyncHomeView extends StatefulWidget {
  const SelfSyncHomeView({super.key});

  @override
  State<SelfSyncHomeView> createState() => _SelfSyncHomeViewState();
}

class _SelfSyncHomeViewState extends State<SelfSyncHomeView> {

  @override
  void initState() {
    super.initState();
    context.read<HomeViewBloc>().add(LoadHomeViewData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewBloc, HomeViewState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SelfSync',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk'),),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<HomeViewBloc>().add(LoadHomeViewData());
                },
              ),
            ],
          ),
          body: state is HomeViewDataLoaded
              ? ResponsiveGridList(desiredItemWidth: 200, 
              minSpacing: 30,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              rowMainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                  Card(
                    elevation: 7,
                    shadowColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text("Notes Summary", style: TextStyle(fontSize: 20)),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        Text('Notes: ${state.homeData.noteCount}', style: const TextStyle(fontSize: 16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image),
                            const SizedBox(width: 5),
                            Text('${state.homeData.totalImagesInNotes}', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Card(
                    elevation: 7,
                    shadowColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text("To-Do Summary", style: TextStyle(fontSize: 20)),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        Text('To-Do: ${state.homeData.todoCount}', style: const TextStyle(fontSize: 16)),
                        Text('Completed: ${state.homeData.completedTodoCount}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),

                  Card(
                    elevation: 7,
                    shadowColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text("Cost Summary", style: TextStyle(fontSize: 20)),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        Text('Monthly: ${state.homeData.monthlyCost}', style: const TextStyle(fontSize: 16)),
                        Text('Yearly: ${state.homeData.yearlyCost}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),

                  Card(
                    elevation: 7,
                    shadowColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text("Memory Summary", style: TextStyle(fontSize: 20)),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        Text('Total: ${state.homeData.totalMemories}', style: const TextStyle(fontSize: 16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image),
                            const SizedBox(width: 5),
                            Text('${state.homeData.totalMemoryImages}', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  )
              ])
              : Center(
                  child: LoadingAnimationWidget.waveDots(color: Colors.purple, size: 60)
          ),
        );
      },
    );
  }
}
