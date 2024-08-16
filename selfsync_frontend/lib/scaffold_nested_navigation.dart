import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selfsync_frontend/common/aws_auth.dart';
import 'package:selfsync_frontend/common/common_functions.dart';

import 'common/models/routes.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(
            key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    if (index == navigationShell.currentIndex) {
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 450 || !isTablet) {
        return ScaffoldWithNavigationDrawer(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      } else {
        return ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      }
    });
  }
}

class ScaffoldWithNavigationDrawer extends StatelessWidget {
  const ScaffoldWithNavigationDrawer({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      body: body,
      endDrawer: NavigationDrawer(
        elevation: 30,
        backgroundColor: Colors.grey[100],
        selectedIndex: selectedIndex,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'SelfSync',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(
            height: 1,
          ),
          //below is a fillter to push the drawer items down
          ...routeDestinations.map((RouteDestination destination) {
            return ListTile(
              leading: destination.icon,
              title: Text(destination.routeLabel),
              selected: routeDestinations.indexOf(destination) == selectedIndex,
              onTap: () {
                if (destination.route == '/signout') {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Sign Out'),
                          content:
                              const Text('Are you sure you want to sign out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                signOutCurrentUser();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        );
                      });
                  return;
                }
                Navigator.pop(context);
                // add some delay to allow the drawer to close
                Future.delayed(const Duration(milliseconds: 200), () {
                  onDestinationSelected(routeDestinations.indexOf(destination));
                });
              },
            );
          }).toList(),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55),
        child: FloatingActionButton(
            heroTag: 'drawer-fab',
            shape: const CircleBorder(),
            hoverColor: Colors.green[800],
            backgroundColor: Colors.blueGrey[600],
            onPressed: () {
              scaffoldKey.currentState!.openEndDrawer();
            },
            child: const Icon(Icons.toc)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            elevation: 10.0,
            indicatorShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            selectedIndex: selectedIndex,
            backgroundColor: const Color.fromARGB(255 ,189, 224,254),
            onDestinationSelected: (int index) {
              final destination = routeDestinations[index];
              if (destination.route == '/signout') {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              signOutCurrentUser();
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      );
                    });
                return;
              }

              onDestinationSelected(index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: routeDestinations.map((RouteDestination destination) {
              return NavigationRailDestination(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: Text(destination.routeLabel),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}
