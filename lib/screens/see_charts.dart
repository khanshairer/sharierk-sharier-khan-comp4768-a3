import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeeCharts extends StatelessWidget {
  const SeeCharts({super.key});

  // Universal text style
  static const buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
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
            SizedBox(
              width: 200, // Wider button width
              child: ElevatedButton(
                onPressed: () => context.go('/bar_chart'),
                child: const Text('Bar Chart', style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, // Wider button width
              child: ElevatedButton(
                onPressed: () => context.go('/line_chart'),
                child: const Text('Line Chart', style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, // Wider button width
              child: ElevatedButton(
                onPressed: () => context.go('/pie_chart'),
                child: const Text('Pie Chart', style: buttonTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
