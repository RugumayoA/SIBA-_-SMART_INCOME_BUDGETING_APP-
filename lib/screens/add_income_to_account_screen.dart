import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/currency_formatter.dart';
import '../models/currency.dart';

class AddIncomeToAccountScreen extends StatefulWidget {
  final String? selectedCategoryId;
  
  const AddIncomeToAccountScreen({super.key, this.selectedCategoryId});

  @override
  State<AddIncomeToAccountScreen> createState() => _AddIncomeToAccountScreenState();
}

class _AddIncomeToAccountScreenState extends State<AddIncomeToAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  BudgetCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income to Account'),
        actions: [
          ElevatedButton(
            onPressed: _saveIncome,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
                currentBalance: 0,
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
                        // Account Selection
                        const Text(
                          'Select Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Account Cards
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
                            labelText: 'Income Amount',
                            prefixText: '${currency.symbol} ',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
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
                            hintText: 'e.g., Salary, Bonus, Payment, etc.',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Warning if no account selected
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
                                    'Please select an account to add income',
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
                      onPressed: _saveIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAVE INCOME',
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

  void _saveIncome() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text;
    
    final provider = context.read<AppProvider>();
    provider.addIncomeToAccount(_selectedCategoryId!, amount, description);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Income added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 