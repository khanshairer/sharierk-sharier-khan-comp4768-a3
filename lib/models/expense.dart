import 'package:hive/hive.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  final String description;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final String category;
  @HiveField(4)
  final int? hiveKey;

  Expense({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.hiveKey,
  });

  // Add this copyWith method
  Expense copyWith({
    String? description,
    double? amount,
    DateTime? date,
    String? category,
    int? hiveKey,
  }) {
    return Expense(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      hiveKey: hiveKey ?? this.hiveKey,
    );
  }
}
