import 'package:expense_tracker/screens/add_edit_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/chart_screens/bar_chart_screen.dart';
import '../screens/chart_screens/line_chart_screen.dart';
import '../screens/chart_screens/pie_chart_screen.dart';
import '../screens/see_charts.dart';
import '../screens/list_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder:
            (context, state) =>
                MaterialPage<void>(key: state.pageKey, child: ListScreen()),
      ),
      GoRoute(
        path: '/add',
        pageBuilder:
            (context, state) =>
                MaterialPage<void>(key: state.pageKey, child: AddEditScreen()),
      ),
      GoRoute(
        path: '/edit/:id', // Added leading slash here
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: AddEditScreen(expenseId: state.pathParameters['id']),
            ),
      ),
      GoRoute(
        path: '/see_charts',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const SeeCharts(),
            ),
      ),
      GoRoute(
        path: '/bar_chart',
        pageBuilder:
            (context, state) =>
                MaterialPage<void>(key: state.pageKey, child: BarChartScreen()),
      ),
      GoRoute(
        path: '/line_chart',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: LineChartScreen(),
            ),
      ),
      GoRoute(
        path: '/pie_chart',
        pageBuilder:
            (context, state) =>
                MaterialPage<void>(key: state.pageKey, child: PieChartScreen()),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No route found for: ${state.uri.toString()}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return Home'),
                ),
              ],
            ),
          ),
        ),
  );
}
