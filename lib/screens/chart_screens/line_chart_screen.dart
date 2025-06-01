import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class LineChartScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LineChartScreen> createState() => _LineChartScreenState();
}

class _LineChartScreenState extends ConsumerState<LineChartScreen> {
  int _selectedTimeRange = 30; // Default to 30 days

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider).expenses;
    final chartData = _processByDate(expenses, _selectedTimeRange);
    final maxAmount = _getMaxAmount(chartData);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenditure Over Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromARGB(255, 226, 180, 43),
          ),
        ),
        leading: Icon(
          Icons.stacked_line_chart,
          color: const Color.fromARGB(255, 226, 180, 43),
          size: 30,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => context.push('/add'),
            tooltip: 'Add Expense',
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(
              Icons.insert_chart,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => context.go('/see_charts'),
            tooltip: 'Back to Charts',
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => _showChartInfo(context),
            tooltip: 'Chart Information',
          ),
        ],
        backgroundColor: Colors.blue[900],
        centerTitle: true,
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
                          maxX:
                              chartData.length > 0
                                  ? chartData.length.toDouble() - 1
                                  : 0,
                          minY: 0,
                          maxY: maxAmount * 1.5,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (spots) =>
                                      spots
                                          .map((spot) {
                                            final index = spot.x.toInt();
                                            if (index < 0 ||
                                                index >= chartData.length)
                                              return null;
                                            return LineTooltipItem(
                                              '${DateFormat('MMM dd').format(chartData[index].date)}\n',
                                              const TextStyle(
                                                color: Colors.white,
                                              ),
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
                                          })
                                          .whereType<LineTooltipItem>()
                                          .toList(),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() %
                                              (_selectedTimeRange ~/ 7) ==
                                          0 ||
                                      value.toInt() ==
                                          (chartData.length > 0
                                              ? chartData.length - 1
                                              : 0)) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat('MMM dd').format(
                                          chartData.length > 0
                                              ? chartData[value.toInt()].date
                                              : DateTime.now(),
                                        ),
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
                                interval: _calculateYInterval(maxAmount),
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

  double _calculateYInterval(double maxAmount) {
    if (maxAmount > 1000) return 200;
    if (maxAmount > 500) return 100;
    if (maxAmount > 200) return 50;
    if (maxAmount > 100) return 25;
    return 10;
  }

  List<DailyTotal> _processByDate(List<Expense> expenses, int days) {
    final dailyMap = <DateTime, double>{};
    final now = DateTime.now();
    final rangeStart = now.subtract(Duration(days: days));

    // Initialize all dates in range with 0
    for (var i = 0; i <= days; i++) {
      final date = rangeStart.add(Duration(days: i));
      dailyMap[DateTime(date.year, date.month, date.day)] = 0;
    }

    // Sum expenses by day
    for (final expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (date.isAfter(rangeStart)) {
        dailyMap.update(
          date,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
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
          selected: _selectedTimeRange == 7,
          onSelected: (_) => setState(() => _selectedTimeRange = 7),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('30 Days'),
          selected: _selectedTimeRange == 30,
          onSelected: (_) => setState(() => _selectedTimeRange = 30),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('90 Days'),
          selected: _selectedTimeRange == 90,
          onSelected: (_) => setState(() => _selectedTimeRange = 90),
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
            onPressed: () => context.push('/add'),
            child: const Text(
              'Add your first expense',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 226, 180, 43),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
              'This line chart shows your daily spending trends.\n\n'
              '• Touch points to see exact amounts\n'
              '• The shaded area indicates spending patterns\n'
              '• Use the time range selector to view different periods',
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
}

class DailyTotal {
  final DateTime date;
  final double amount;

  DailyTotal(this.date, this.amount);
}
