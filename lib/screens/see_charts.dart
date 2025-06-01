import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeeCharts extends StatelessWidget {
  const SeeCharts({super.key});

  // Define uniform text style
  static const buttonTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 226, 180, 43),
    letterSpacing: 0.6,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.push('/add'),
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            tooltip: 'Add Expense',
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(
              Icons.home,
              color: Color.fromARGB(255, 226, 180, 43),
            ),

            tooltip: 'Home',
          ),
        ],
        title: const Text(
          'All Charts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 226, 180, 43),
            fontSize: 24,
            letterSpacing: 0.6,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: Icon(
          Icons.insert_chart,
          color: const Color.fromARGB(255, 226, 180, 43),
          size: 30,
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
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 6,
                ),
                child: const Text('Bar Chart', style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 30),
            // Line Chart Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/line_chart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text('Line Chart', style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 30),
            // Pie Chart Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/pie_chart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
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
