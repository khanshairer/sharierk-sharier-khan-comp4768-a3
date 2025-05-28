import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/expense.dart';
import 'routing/app_router.dart';
import 'providers/expense_provider.dart';

final routerProvider = Provider((ref) {
  return AppRouter().router;
});

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final expenseBox = ref.watch(expenseBoxProvider);

    return expenseBox.when(
      loading:
          () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (error, stack) => MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error initializing database: $error')),
            ),
          ),
      data: (box) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      },
    );
  }
}
