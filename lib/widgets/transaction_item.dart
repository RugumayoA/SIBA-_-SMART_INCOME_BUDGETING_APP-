import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';
import '../utils/currency_formatter.dart';

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
    final provider = Provider.of<AppProvider>(context);
    final currency = provider.currentProject?.currency;
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
          currency != null 
            ? CurrencyFormatter.formatCurrency(transaction.amount, currency)
            : CurrencyFormatter.formatUGX(transaction.amount),
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