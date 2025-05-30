import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'bar',
                    child: ListTile(
                      leading: Icon(Icons.bar_chart),
                      title: Text('Bar Chart'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'line',
                    child: ListTile(
                      leading: Icon(Icons.show_chart),
                      title: Text('Line Chart'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'pie',
                    child: ListTile(
                      leading: Icon(Icons.pie_chart),
                      title: Text('Pie Chart'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add',
                    child: ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Add Expense'),
                    ),
                  ),
                ],
            onSelected: (value) {
              switch (value) {
                case 'bar':
                  context.go('/charts/bar');
                  break;
                case 'line':
                  context.go('/charts/line');
                  break;
                case 'pie':
                  context.go('/charts/pie');
                  break;
                case 'add':
                  context.go('/add');
                  break;
              }
            },
          ),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}
