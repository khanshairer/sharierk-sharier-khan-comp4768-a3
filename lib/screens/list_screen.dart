// lib/screens/list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/edit/new'),
          ),
        ],
      ),
      body: _buildBody(state, context, ref),
    );
  }

  Widget _buildBody(ExpenseState state, BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    if (state.expenses.isEmpty) {
      return const Center(child: Text('No expenses yet. Tap + to add one!'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(expenseProvider.notifier)._loadExpenses(),
      child: ListView.builder(
        itemCount: state.expenses.length,
        itemBuilder: (context, index) {
          final expense = state.expenses[index];
          return Dismissible(
            key: Key(expense.key.toString()),
            background: Container(color: Colors.red),
            confirmDismiss: (_) => _confirmDelete(context, expense.key, ref),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(expense.name),
                subtitle: Text('\$${expense.amount.toStringAsFixed(2)}'),
                trailing: Text(expense.date.toString()),
                onTap: () => context.push('/edit/${expense.key}'),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    int key,
    WidgetRef ref,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Expense'),
                content: const Text('Are you sure?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(expenseProvider.notifier).deleteExpense(key);
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
