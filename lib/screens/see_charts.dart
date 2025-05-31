import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeeCharts extends StatelessWidget {
  const SeeCharts({super.key});

  // Define uniform text style
  static const buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.push('/add'),
            icon: const Icon(Icons.add),
            tooltip: 'Add Expense',
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
        title: const Text(
          'See Charts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bar Chart Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/bar_chart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text('Bar Chart', style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 20),
            // Line Chart Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/line_chart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text('Line Chart', style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 20),
            // Pie Chart Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/pie_chart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text('Pie Chart', style: buttonTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
