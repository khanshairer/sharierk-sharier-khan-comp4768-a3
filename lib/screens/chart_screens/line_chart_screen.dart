import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class LineChartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider).expenses;
    final chartData = _processByDate(expenses);
    final maxAmount = _getMaxAmount(chartData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Over Time'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/add'),
            tooltip: 'Add Expense',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.insert_chart),
            onPressed: () => context.go('/see_charts'),
            tooltip: 'Back to Charts',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChartInfo(context),
            tooltip: 'Chart Information',
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
                    _buildTimeRangeSelector(context),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: chartData.length.toDouble() - 1,
                          minY: 0,
                          maxY: maxAmount * 1.2,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (spots) =>
                                      spots.map((spot) {
                                        return LineTooltipItem(
                                          '${DateFormat('MMM dd').format(chartData[spot.x.toInt()].date)}\n',
                                          const TextStyle(color: Colors.white),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '\$${spot.y.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 7 == 0 ||
                                      value.toInt() == chartData.length - 1) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat(
                                          'MMM dd',
                                        ).format(chartData[value.toInt()].date),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (value, meta) => Text(
                                      '\$${value.toInt()}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                reservedSize: 40,
                                interval: maxAmount > 100 ? 50 : 20,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  chartData.asMap().entries.map((entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.amount,
                                    );
                                  }).toList(),
                              isCurved: true,
                              color: Colors.blueAccent,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withOpacity(0.3),
                                    Colors.blueAccent.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _safeNavigate(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(route);
      }
    });
  }

  List<DailyTotal> _processByDate(List<Expense> expenses) {
    final dailyMap = <DateTime, double>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Initialize all dates in range with 0
    for (var i = 0; i <= 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      dailyMap[DateTime(date.year, date.month, date.day)] = 0;
    }

    // Sum expenses by day
    for (final expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (dailyMap.containsKey(date)) {
        dailyMap[date] = dailyMap[date]! + expense.amount;
      }
    }

    // Convert to sorted list
    return dailyMap.entries.map((e) => DailyTotal(e.key, e.value)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double _getMaxAmount(List<DailyTotal> data) {
    if (data.isEmpty) return 100;
    return data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('7 Days'),
          selected: false,
          onSelected: (_) {},
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('30 Days'),
          selected: true,
          onSelected: (_) {},
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('90 Days'),
          selected: false,
          onSelected: (_) {},
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
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
            onPressed: () => _safeNavigate(context, '/add'),
            child: const Text('Add your first expense'),
          ),
        ],
      ),
    );
  }

  void _showChartInfo(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Chart Information'),
                content: const Text(
                  'This line chart shows your daily spending trends over the last 30 days.\n\n'
                  '• Touch points to see exact amounts\n'
                  '• The shaded area indicates spending patterns',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ],
              ),
        );
      }
    });
  }
}

class DailyTotal {
  final DateTime date;
  final double amount;

  DailyTotal(this.date, this.amount);
}
