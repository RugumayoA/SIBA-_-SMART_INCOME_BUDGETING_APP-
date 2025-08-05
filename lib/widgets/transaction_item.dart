import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final BudgetCategory category;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final formattedDate = dateFormat.format(transaction.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            transaction.isExpense ? Icons.remove : Icons.add,
            color: category.color,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$formattedDate • ${category.name}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          'UGX ${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.isExpense ? Colors.red : Colors.green,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 