import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/list_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/chart_screens/bar_chart_screen.dart';
import '../screens/chart_screens/line_chart_screen.dart';
import '../screens/chart_screens/pie_chart_screen.dart';

class AppRouter {
  // Route names as constants for easy reference
  static const String homeRoute = '/';
  static const String addRoute = 'add';
  static const String editRoute = 'edit/:id';
  static const String barChartRoute = 'charts/bar';
  static const String lineChartRoute = 'charts/line';
  static const String pieChartRoute = 'charts/pie';

  final GoRouter router = GoRouter(
    routes: [
      // Main list view (home)
      GoRoute(
        path: homeRoute,
        builder: (context, state) => const ListScreen(),
        routes: [
          // Add new expense
          GoRoute(
            path: addRoute,
            builder: (context, state) => const AddEditScreen(),
          ),
          
          // Edit existing expense
          GoRoute(
            path: editRoute,
            builder: (context, state) => AddEditScreen(
              expenseId: state.pathParameters['id'],
            ),
          ),

          // Chart routes
          GoRoute(
            path: barChartRoute,
            builder: (context, state) => BarChartScreen(),
          ),
          GoRoute(
            path: lineChartRoute,
            builder: (context, state) => LineChartScreen(),
          ),
          GoRoute(
            path: pieChartRoute,
            builder: (context, state) => PieChartScreen(),
          ),
        ],
      ),
    ],
    // Error page for undefined routes
    errorBuilder: (context, state) => Scaffold(
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
              onPressed: () => context.go(homeRoute),
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    ),
    // Optional redirect logic
    redirect: (context, state) {
      // Add any route guards or redirect logic here
      return null; // Return null to proceed with normal routing
    },
  );

  // Helper methods for navigation
  static void goToAddScreen(BuildContext context) => context.go('/$addRoute');
  static void goToEditScreen(BuildContext context, String id) => 
    context.go('/$editRoute'.replaceFirst(':id', id));
  static void goToBarChart(BuildContext context) => context.go('/$barChartRoute');
  static void goToLineChart(BuildContext context) => context.go('/$lineChartRoute');
  static void goToPieChart(BuildContext context) => context.go('/$pieChartRoute');
}