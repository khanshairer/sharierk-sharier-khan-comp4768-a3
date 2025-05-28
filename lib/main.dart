import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/expense.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapter
  Hive.registerAdapter(ExpenseAdapter());

  // Open a box
  await Hive.openBox<Expense>('expenses');

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  // Use the router instance you created in app_router.dart
  final router = AppRouter().router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Use the GoRouter configuration
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
