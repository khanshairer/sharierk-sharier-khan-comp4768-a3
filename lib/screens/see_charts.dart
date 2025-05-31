import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeeCharts extends StatelessWidget {
  const SeeCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.push('/add'), // Changed to path
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
          ),
        ],
        title: const Text('See Charts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/bar_chart'), // Changed to path
              child: const Text('Bar Chart'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/line_chart'), // Changed to path
              child: const Text('Line Chart'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/pie_chart'), // Changed to path
              child: const Text('Pie Chart'),
            ),
          ],
        ),
      ),
    );
  }
}
