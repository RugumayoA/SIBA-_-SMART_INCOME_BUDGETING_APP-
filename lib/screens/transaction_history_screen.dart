import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  
  const TransactionHistoryScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? selectedCategoryId;
  String? selectedCategoryName;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed category if any
    selectedCategoryId = widget.categoryId;
    selectedCategoryName = widget.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategoryName != null ? '$selectedCategoryName History' : 'Transaction History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                if (value == 'all') {
                  selectedCategoryId = null;
                  selectedCategoryName = null;
                } else {
                  // Parse the category info from the value
                  final parts = value.split('|');
                  if (parts.length == 2) {
                    selectedCategoryId = parts[0];
                    selectedCategoryName = parts[1];
                  }
                }
              });
            },
            itemBuilder: (BuildContext context) {
              final provider = Provider.of<AppProvider>(context, listen: false);
              final categories = provider.categories;
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.list, color: selectedCategoryId == null ? Colors.blue : Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'All Transactions',
                        style: TextStyle(
                          color: selectedCategoryId == null ? Colors.blue : Colors.grey,
                          fontWeight: selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                ...categories.map((category) => PopupMenuItem<String>(
                  value: '${category.id}|${category.name}',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: selectedCategoryId == category.id ? Colors.blue : Colors.grey,
                          fontWeight: selectedCategoryId == category.id ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ];
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final allTransactions = provider.getAllTransactions();
          final transactions = selectedCategoryId != null 
              ? provider.getTransactionsForCategory(selectedCategoryId!)
              : allTransactions;
          
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    selectedCategoryId != null ? 'No transactions for $selectedCategoryName' : 'No transactions yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedCategoryId != null 
                        ? 'Add income or expenses to $selectedCategoryName to see its history'
                        : 'Add income or expenses to see transaction history',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
              final formattedDate = dateFormat.format(transaction.date);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: transaction.isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transaction.isExpense ? Icons.remove : Icons.add,
                      color: transaction.isExpense ? Colors.red : Colors.green,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.categoryName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'UGX ${transaction.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: transaction.isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        transaction.isExpense ? 'Expense' : 'Income',
                        style: TextStyle(
                          fontSize: 12,
                          color: transaction.isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 