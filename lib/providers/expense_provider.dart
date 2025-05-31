import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';

/// Represents the state of the expense list with loading and error indicators
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  ExpenseState({this.expenses = const [], this.isLoading = false, this.error});

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Manages state and business logic for expenses
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final Box<Expense> _box;

  ExpenseNotifier(this._box) : super(ExpenseState()) {
    loadExpenses();
  }

  /// Load expenses from Hive
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      final expenses = _box.values.toList();
      state = state.copyWith(expenses: expenses, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load expenses: ${e.toString()}',
      );
      debugPrint(e.toString());
    }
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    state = state.copyWith(isLoading: true);
    try {
      final key = await _box.add(expense);
      final newExpense = expense.copyWith(hiveKey: key);
      await _box.put(key, newExpense);
      await loadExpenses(); // Refresh the list
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add expense: ${e.toString()}',
      );
      debugPrint(e.toString());
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(int key, Expense newExpense) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedExpense = newExpense.copyWith(hiveKey: key);
      await _box.put(key, updatedExpense);
      await loadExpenses(); // Refresh the list
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update expense: ${e.toString()}',
      );
      debugPrint(e.toString());
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(int key) async {
    state = state.copyWith(isLoading: true);
    try {
      await _box.delete(key);
      await loadExpenses(); // Refresh the list
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete expense: ${e.toString()}',
      );
      debugPrint(e.toString());
    }
  }

  /// Clear all expenses
  Future<void> clearAllExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      await _box.clear();
      state = state.copyWith(expenses: [], isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear expenses: ${e.toString()}',
      );
      debugPrint(e.toString());
    }
  }

  /// Get expense by key
  Expense? getExpense(int key) {
    try {
      return _box.get(key);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}

/// Provider for the Hive box
final expenseBoxProvider = FutureProvider<Box<Expense>>((ref) async {
  await Hive.openBox<Expense>('expenses');
  return Hive.box<Expense>('expenses');
});

/// Main provider for expense state management
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((
  ref,
) {
  final box = ref
      .watch(expenseBoxProvider)
      .maybeWhen(
        data: (box) => box,
        orElse: () => throw Exception('Hive box not initialized'),
      );
  return ExpenseNotifier(box);
});
