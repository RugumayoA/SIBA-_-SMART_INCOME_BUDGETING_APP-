import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/currency_formatter.dart';
import '../models/currency.dart';
//THIS IS THE ADD EXPENSE SCREEN

class AddExpenseScreen extends StatefulWidget {
  final String? selectedCategoryId;
  
  const AddExpenseScreen({super.key, this.selectedCategoryId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  BudgetCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
        final currency = provider.currentProject?.currency ?? Currencies.ugx;
          // Update selected category
          if (_selectedCategoryId != null) {
            _selectedCategory = provider.categories.firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => provider.categories.isNotEmpty ? provider.categories.first : BudgetCategory(
                id: '',
                name: '',
                allocatedAmount: 0,
                color: Colors.grey,
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Selection
                        const Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Category Cards
                        ...provider.categories.map((category) {
                          final isSelected = _selectedCategoryId == category.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected ? category.color.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                'Current Balance: ${CurrencyFormatter.formatCurrency(category.currentBalance, currency)}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 24),
                        
                        // Amount Input
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Expense Amount',
                            prefixText: '${currency.symbol} ',
                            border: const OutlineInputBorder(),
                            suffixIcon: _selectedCategory != null && _amountController.text.isNotEmpty
                                ? Icon(
                                    (double.tryParse(_amountController.text) ?? 0) > _selectedCategory!.currentBalance
                                        ? Icons.warning
                                        : Icons.check_circle,
                                    color: (double.tryParse(_amountController.text) ?? 0) > _selectedCategory!.currentBalance
                                        ? Colors.red
                                        : Colors.green,
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Trigger rebuild for real-time validation
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            if (_selectedCategory != null && amount > _selectedCategory!.currentBalance) {
                              return 'Amount exceeds available balance of ${CurrencyFormatter.formatCurrency(_selectedCategory!.currentBalance, currency)}';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description Input
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Food, Transport, Bills, etc.',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Selected Category Details
                        if (_selectedCategory != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedCategory!.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _selectedCategory!.color),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedCategory!.name} Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedCategory!.color,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Current Balance:'),
                                    Text(
                                      CurrencyFormatter.formatCurrency(_selectedCategory!.currentBalance, currency),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedCategory!.currentBalance <= 0 ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Spent:'),
                                    Text(
                                      CurrencyFormatter.formatCurrency(_selectedCategory!.spentAmount, currency),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                // Balance Status Indicator
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory!.currentBalance <= 0 
                                        ? Colors.red.withOpacity(0.1)
                                        : _selectedCategory!.currentBalance < 1000
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _selectedCategory!.currentBalance <= 0 
                                          ? Colors.red
                                          : _selectedCategory!.currentBalance < 1000
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selectedCategory!.currentBalance <= 0 
                                            ? Icons.warning
                                            : _selectedCategory!.currentBalance < 1000
                                                ? Icons.info
                                                : Icons.check_circle,
                                        size: 16,
                                        color: _selectedCategory!.currentBalance <= 0 
                                            ? Colors.red
                                            : _selectedCategory!.currentBalance < 1000
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedCategory!.currentBalance <= 0 
                                              ? 'No funds available'
                                              : _selectedCategory!.currentBalance < 1000
                                                  ? 'Low balance warning'
                                                  : 'Sufficient funds available',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedCategory!.currentBalance <= 0 
                                                ? Colors.red
                                                : _selectedCategory!.currentBalance < 1000
                                                    ? Colors.orange
                                                    : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Warning if no category selected
                        if (_selectedCategoryId == null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Please select a category to add expense',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Save Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAVE EXPENSE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text;
    
    // Check if expense amount exceeds available balance
    if (_selectedCategory != null && amount > _selectedCategory!.currentBalance) {
      _showInsufficientFundsDialog(amount, description);
      return;
    }
    
    final provider = context.read<AppProvider>();
    provider.addExpense(_selectedCategoryId!, description, amount);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInsufficientFundsDialog(double requestedAmount, String description) {
    final provider = context.read<AppProvider>();
    final currency = provider.currentProject?.currency ?? Currencies.ugx;
    final availableBalance = _selectedCategory!.currentBalance;
    final shortfall = requestedAmount - availableBalance;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Insufficient Funds'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are trying to spend more money than available in "${_selectedCategory!.name}".',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Requested Amount:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        CurrencyFormatter.formatCurrency(requestedAmount, currency),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available Balance:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        CurrencyFormatter.formatCurrency(availableBalance, currency),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shortfall:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        CurrencyFormatter.formatCurrency(shortfall, currency),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'What would you like to do?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (availableBalance > 0) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _amountController.text = availableBalance.toString();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Amount adjusted to available balance: ${CurrencyFormatter.formatCurrency(availableBalance, currency)}'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Use Available Balance', style: TextStyle(color: Colors.white)),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedWithNegativeBalance(requestedAmount, description);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Proceed Anyway', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _proceedWithNegativeBalance(double amount, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Overdraft'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'This will put "${_selectedCategory!.name}" into a negative balance.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to continue?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              final provider = context.read<AppProvider>();
              provider.addExpense(_selectedCategoryId!, description, amount);
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense added with negative balance!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Overdraft', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 