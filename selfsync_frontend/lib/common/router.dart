import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:selfsync_frontend/common/service/storage_service.dart';
import 'package:selfsync_frontend/feature/budget/data/budget_provider.dart';
import 'package:selfsync_frontend/feature/home/data/home_provider.dart';
import 'package:selfsync_frontend/feature/memories/bloc/memories_grid_bloc.dart';
import 'package:selfsync_frontend/feature/memories/cubit/memories_details_cubit.dart';
import 'package:selfsync_frontend/feature/memories/ui/memories_home.dart';
import 'package:selfsync_frontend/feature/notes/bloc/import_notes_list_bloc.dart';
import 'package:selfsync_frontend/feature/notes/bloc/notes_details_bloc.dart';
import 'package:selfsync_frontend/feature/notes/data/notes_provider.dart';
import 'package:selfsync_frontend/feature/notes/data/notes_repository.dart';
import 'package:selfsync_frontend/feature/notes/ui/note_edit_view.dart';
import 'package:selfsync_frontend/feature/notes/ui/notes_list.dart';
import 'package:selfsync_frontend/feature/notes/ui/note_details.dart';
import 'package:selfsync_frontend/feature/spacenews/bloc/space_home_bloc.dart';
import 'package:selfsync_frontend/feature/spacenews/ui/space_news_home.dart';
import 'package:selfsync_frontend/feature/todos/bloc/todo_bloc.dart';
import 'package:selfsync_frontend/feature/todos/data/todo_provider.dart';
import 'package:selfsync_frontend/feature/todos/data/todo_repository.dart';
import 'package:selfsync_frontend/feature/todos/ui/todos_home.dart';
import 'package:selfsync_frontend/feature/home/ui/selfsync_home_view.dart';

import '../feature/budget/bloc/budget_home_bloc.dart';
import '../feature/budget/data/budget_repository.dart';
import '../feature/budget/ui/budget_home.dart';
import '../feature/home/bloc/home_view_bloc.dart';
import '../feature/home/data/home_repository.dart';
import '../feature/memories/data/memories_provider.dart';
import '../feature/memories/data/memories_repository.dart';
import '../feature/memories/model/memories_model.dart';
import '../feature/memories/ui/memories_details_view.dart';
import '../feature/notes/model/notes_model.dart';
import '../feature/spacenews/repository/space_news_provider.dart';
import '../feature/spacenews/repository/space_news_repository.dart';
import '../scaffold_nested_navigation.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final goRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RepositoryProvider(
          create: (context) =>
              NotesRepository(NotesProvider(storageService: StorageService())),
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => MaterialPage(
                  child: RepositoryProvider(
                create: (context) => HomeRepository(HomeProvider()),
                child: BlocProvider(
                  create: (context) => HomeViewBloc(
                    context.read<HomeRepository>(),
                  ),
                  child: const SelfSyncHomeView(),
                ),
              ))
            ),
          ],
        ),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/memorieshome',
            pageBuilder: (context, state) => MaterialPage(
                child: RepositoryProvider(
              create: (context) => MemoriesRepository(
                    MemoriesProvider(storageService: StorageService()),
              ),
              child: BlocProvider(
                create: (context) =>
                    MemoriesGridBloc(context.read<MemoriesRepository>()),
                child: const MemoriesHome(),
              ),
            )),
            routes: [
              GoRoute(
                  path: 'details',
                  builder: (context, state) => BlocProvider(
                        create: (context) =>
                            MemoriesDetailsCubit(state.extra as MemoriesModel),
                        child: const MemoriesDetailsView(),
                      )),
            ],
          ),
        ]),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            // Shopping Cart
            GoRoute(
              path: '/todoshome',
              pageBuilder: (context, state) => MaterialPage(
                child: RepositoryProvider(
                  create: (context) => TodoRepository(TodosProvider()),
                  child: BlocProvider(
                    create: (context) => TodoBloc(
                      context.read<TodoRepository>(),
                    ),
                    child: const TodosHome(),
                  ),
                ),
              )
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            // Shopping Cart
            GoRoute(
              path: '/noteshome',
              pageBuilder: (context, state) => MaterialPage(
                child: BlocProvider(
                  create: (context) =>
                      NotesListBloc(context.read<NotesRepository>()),
                  child: const NotesList(),
                ),
              ),
              routes: [
                GoRoute(
                    path: 'details',
                    pageBuilder: (context, state) => MaterialPage(
                          child: BlocProvider(
                            create: (context) => NotesDetailsBloc(
                                state.extra as NoteItem,
                                context.read<NotesRepository>()),
                            child: const NoteDetailsView(),
                          ),
                        ),
                    routes: [
                      GoRoute(
                          path: 'edit',
                          pageBuilder: (context, state) => MaterialPage(
                                child: NoteEditView(
                                  note: state.extra as NoteItem,
                                ),
                              ))
                    ]),
              ],
            ),
          ],
        ),

        // add budget route
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/budgethome',
              pageBuilder: (context, state) => MaterialPage(
                child: RepositoryProvider(
                  create: (context) => BudgetRepository(
                    budgetProvider: BudgetProvider(),
                    selectedYear: DateTime.now().year,
                    selectedMonth: DateTime.now().month,
                  ),
                  child: BlocProvider(
                    create: (context) => BudgetHomeBloc(
                      context.read<BudgetRepository>(),
                    ),
                    child: const BudgetHome(),
                  ),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/spacehome',
              pageBuilder: (context, state) => MaterialPage(
                  child: RepositoryProvider(
                create: (context) => SpaceNewsRepository(SpaceNewsProvider()),
                child: BlocProvider(
                  create: (context) => SpaceHomeBloc(
                    context.read<SpaceNewsRepository>(),
                  ),
                  child: const SpaceNewsHome(),
                ),
              )),
            ),
          ],
        ),
      ],
    ),
  ],
);
