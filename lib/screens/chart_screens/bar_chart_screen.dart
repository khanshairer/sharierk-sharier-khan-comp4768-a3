import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Fixed typo
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense.dart'; // Fixed path
import '../../providers/expense_provider.dart';
import '../add_edit_screen.dart';

class BarChartScreen extends ConsumerWidget {
  static const List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Utilities',
    'Other',
  ];

  static const List<Color> categoryColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider).expenses;
    final chartData = _processByCategory(expenses);
    final maxAmount = _getMaxAmount(chartData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending by Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChartInfo(context),
          ),
        ],
      ),
      body:
          expenses.isEmpty
              ? _buildEmptyState(context)
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildChartLegend(chartData),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxAmount * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipBgColor: (_) => Colors.black87,
                              getTooltipItem:
                                  (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) => BarTooltipItem(
                                    '${categories[group.x.toInt()]}\n',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '\$${rod.toY.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                              maxContentWidth: 150,
                              direction: TooltipDirection.top,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (value, meta) => Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        categories[value.toInt()],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (value, meta) => Text(
                                      '\$${value.toInt()}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                reservedSize: 40,
                                interval: maxAmount > 100 ? 50 : 20,
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          barGroups:
                              chartData
                                  .map(
                                    (data) => BarChartGroupData(
                                      x: data.index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: data.amount,
                                          color: categoryColors[data.index],
                                          width: 22,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          backDrawRodData:
                                              BackgroundBarChartRodData(
                                                show: true,
                                                toY: maxAmount,
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  List<ChartData> _processByCategory(List<Expense> expenses) {
    final categoryMap = <String, double>{};

    for (final expense in expenses) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return ChartData(index, categoryMap[category] ?? 0, category);
    }).toList();
  }

  double _getMaxAmount(List<ChartData> data) {
    if (data.isEmpty) return 100;
    return data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  Widget _buildChartLegend(List<ChartData> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            data
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: categoryColors[item.index],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(item.label, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 50,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'No expense data available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditScreen()),
                ),
            child: const Text('Add your first expense'),
          ),
        ],
      ),
    );
  }

  void _showChartInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chart Information'),
            content: const Text(
              'This chart visualizes your spending distribution across different categories.\n\n'
              '• Tap on bars to see exact amounts\n'
              '• Colors represent different categories',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }
}

class ChartData {
  final int index;
  final double amount;
  final String label;

  ChartData(this.index, this.amount, this.label);
}
