import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/list_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/chart_screens/bar_chart_screen.dart';
import '../screens/chart_screens/line_chart_screen.dart';
import '../screens/chart_screens/pie_chart_screen.dart';

final router = GoRouter(
  routes: [
    // Main list view
    GoRoute(
      path: '/',
      builder: (context, state) => const ListScreen(),
      routes: [
        // Add/edit expense (with ID parameter for edits)
        GoRoute(
          path: 'edit/:id',
          builder:
              (context, state) =>
                  AddEditScreen(expenseId: state.pathParameters['id']),
        ),

        // Chart routes
        GoRoute(
          path: 'charts/bar',
          builder: (context, state) => const BarChartScreen(),
        ),
        GoRoute(
          path: 'charts/line',
          builder: (context, state) => const LineChartScreen(),
        ),
        GoRoute(
          path: 'charts/pie',
          builder: (context, state) => const PieChartScreen(),
        ),
      ],
    ),
  ],
  // Optional redirect logic
  redirect: (context, state) {
    // Example: Check auth status
    // final isLoggedIn = context.read(authProvider).isAuthenticated;
    // if (!isLoggedIn && !state.matchedLocation.startsWith('/login')) {
    //   return '/login';
    // }
    return null;
  },
);
