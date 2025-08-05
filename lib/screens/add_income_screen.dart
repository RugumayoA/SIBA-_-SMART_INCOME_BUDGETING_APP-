import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final Map<String, TextEditingController> _allocationControllers = {};
  double _totalIncome = 0.0;
  double _allocatedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final provider = context.read<AppProvider>();
    for (var category in provider.categories) {
      _allocationControllers[category.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    for (var controller in _allocationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateAllocations() {
    setState(() {
      _allocatedAmount = 0.0;
      for (var controller in _allocationControllers.values) {
        final amount = double.tryParse(controller.text) ?? 0.0;
        _allocatedAmount += amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
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
                        // Total Income Input
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Income Amount',
                            prefixText: 'UGX ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter income amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _totalIncome = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Allocation Section
                        const Text(
                          'Allocate to Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Category Allocation Fields
                        ...provider.categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: _allocationControllers[category.id],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '${category.name} Allocation',
                                prefixText: 'UGX ',
                                border: const OutlineInputBorder(),
                                suffixIcon: Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: category.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                _updateAllocations();
                              },
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 24),
                        
                        // Summary Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Allocation Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Income:'),
                                  Text(
                                    'UGX ${_totalIncome.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Allocated:'),
                                  Text(
                                    'UGX ${_allocatedAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Remaining:'),
                                  Text(
                                    'UGX ${(_totalIncome - _allocatedAmount).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (_totalIncome - _allocatedAmount) < 0 
                                          ? Colors.red 
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        if (_totalIncome > 0 && _allocatedAmount != _totalIncome)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _allocatedAmount > _totalIncome
                                  ? '⚠️ Allocated amount exceeds total income'
                                  : 'ℹ️ ${(_totalIncome - _allocatedAmount).toStringAsFixed(0)} UGX not allocated',
                              style: TextStyle(
                                color: _allocatedAmount > _totalIncome ? Colors.red : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
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
    
    if (_allocatedAmount != _totalIncome) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Allocation Mismatch'),
          content: Text(
            _allocatedAmount > _totalIncome
                ? 'Allocated amount (UGX ${_allocatedAmount.toStringAsFixed(0)}) exceeds total income (UGX ${_totalIncome.toStringAsFixed(0)}). Please adjust allocations.'
                : 'Only UGX ${_allocatedAmount.toStringAsFixed(0)} out of UGX ${_totalIncome.toStringAsFixed(0)} is allocated. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processIncome();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      _processIncome();
    }
  }

  void _processIncome() {
    final provider = context.read<AppProvider>();
    final allocations = <String, double>{};
    
    for (var entry in _allocationControllers.entries) {
      final amount = double.tryParse(entry.value.text) ?? 0.0;
      if (amount > 0) {
        allocations[entry.key] = amount;
      }
    }
    
    provider.addIncome(_totalIncome, allocations);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Income added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 