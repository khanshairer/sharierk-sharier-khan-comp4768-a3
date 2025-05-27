import 'package:hive/hive.dart';

part 'expense.g.dart'; // Generated file

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

  Expense({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}
