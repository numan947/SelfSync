import 'package:flutter/material.dart';

class RouteDestination {
  final String routeLabel;
  final Widget icon;
  final String route;
  final Widget selectedIcon;

  const RouteDestination(
      {required this.routeLabel,
      required this.route,
      required this.icon,
      required this.selectedIcon});
}

const List<RouteDestination> routeDestinations = <RouteDestination>[
  RouteDestination(
    routeLabel: 'Home',
    route: '/',
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
  ),

  // add memory route
  RouteDestination(
    routeLabel: 'Memories',
    route: '/memorieshome',
    icon: Icon(Icons.photo_library_outlined),
    selectedIcon: Icon(Icons.photo_library),
  ),

  RouteDestination(
    routeLabel: 'Todos',
    route: '/todoshome',
    icon: Icon(Icons.fact_check_outlined),
    selectedIcon: Icon(Icons.fact_check),
  ),
  RouteDestination(
    routeLabel: 'Notes',
    route: '/noteshome',
    icon: Icon(Icons.note_outlined),
    selectedIcon: Icon(Icons.note),
  ),
  RouteDestination(
    routeLabel: 'Finance',
    route: '/budgethome',
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
  ),
  RouteDestination(
    routeLabel: 'SpaceNews',
    route: '/spacehome',
    icon: Icon(Icons.rocket_launch_outlined),
    selectedIcon: Icon(Icons.rocket_launch),
  ),
  RouteDestination(
    routeLabel: 'Sign Out',
    route: '/signout',
    icon: Icon(Icons.logout_outlined),
    selectedIcon: Icon(Icons.logout),
  ),
];