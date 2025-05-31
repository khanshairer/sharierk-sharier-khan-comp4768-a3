import 'package:expense_tracker/screens/add_edit_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/chart_screens/bar_chart_screen.dart';
import '../screens/chart_screens/line_chart_screen.dart';
import '../screens/chart_screens/pie_chart_screen.dart';
import '../screens/see_charts.dart';
import '../screens/list_screen.dart';
import '../screens/add_edit_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey, // Preserves state during transitions
              child: ListScreen(), // Your initial screen widget
            ),
      ),
      GoRoute(
        path: '/add',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey, // Preserves state during transitions
              child:
                  AddEditScreen(), // Replace with your add expense screen widget
            ),
      ),
      GoRoute(
        path: 'edit/:id',
        builder:
            (context, state) =>
                AddEditScreen(expenseId: state.pathParameters['id']),
      ),

      GoRoute(
        path: '/see_charts',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey, // Preserves state during transitions
              child: const SeeCharts(), // Your screen widget
            ),
      ),
      GoRoute(
        path: '/bar_chart',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey, // Preserves state during transitions
              child: BarChartScreen(), // Your screen widget
            ),
      ),
      GoRoute(
        path: '/line_chart',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey, // Preserves state during transitions
              child:
                  LineChartScreen(), // Replace with your line chart screen widget
            ),
      ),
      GoRoute(
        path: '/pie_chart',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey, // Preserves state during transitions
              child:
                  PieChartScreen(), // Replace with your pie chart screen widget
            ),
      ),
    ],
  );
}
