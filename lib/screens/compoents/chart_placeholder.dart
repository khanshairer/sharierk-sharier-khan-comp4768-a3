// chart_placeholder.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartPlaceholder extends StatelessWidget {
  final Widget chart;
  final String title;

  const ChartPlaceholder({required this.chart, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            AspectRatio(aspectRatio: 1.7, child: chart),
          ],
        ),
      ),
    );
  }
}
