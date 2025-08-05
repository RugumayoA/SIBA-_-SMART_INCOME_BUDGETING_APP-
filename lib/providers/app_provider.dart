import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class BudgetCategory {
  final String id;
  final String name;
  final double allocatedAmount;
  final double spentAmount;
  final double currentBalance;
  final Color color;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
    this.currentBalance = 0.0,
    required this.color,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get spentPercentage => allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'currentBalance': currentBalance,
      'color': color.value,
    };
  }

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'],
      name: json['name'],
      allocatedAmount: json['allocatedAmount']?.toDouble() ?? 0.0,
      spentAmount: json['spentAmount']?.toDouble() ?? 0.0,
      currentBalance: json['currentBalance']?.toDouble() ?? 0.0,
      color: Color(json['color']),
    );
  }
}

class TransactionModel {
  final String id;
  final String categoryId;
  final String description;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String categoryName;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.categoryName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
      'categoryName': categoryName,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      categoryId: json['categoryId'],
      description: json['description'],
      amount: json['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      isExpense: json['isExpense'] ?? false,
      categoryName: json['categoryName'] ?? '',
    );
  }
}

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _userName = '';
  int _selectedIndex = 0;
  List<BudgetCategory> _categories = [];
  List<TransactionModel> _transactions = [];
  double _totalIncome = 0.0;

  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  int get selectedIndex => _selectedIndex;
  List<BudgetCategory> get categories => _categories;
  List<TransactionModel> get transactions => _transactions;
  double get totalIncome => _totalIncome;

  // Total money across all accounts (current balance minus spent)
  double get totalMoney => _categories.fold(0.0, (sum, category) => sum + category.currentBalance);
  
  // Total spent across all accounts
  double get totalSpent => _categories.fold(0.0, (sum, category) => sum + category.spentAmount);
  
  // Total available money (current balance minus spent)
  double get totalAvailable => totalMoney - totalSpent;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Loading data from Firebase...');
      
      // Initialize default categories if needed
      await FirebaseService.initializeDefaultCategories();
      
      // Load categories from Firebase
      _categories = await FirebaseService.getCategories();
      print('Loaded ${_categories.length} categories from Firebase');
      for (var category in _categories) {
        print('  - ${category.name} (ID: ${category.id}): Balance=${category.currentBalance}');
      }
      
      // Load transactions from Firebase
      _transactions = await FirebaseService.getTransactions();
      print('Loaded ${_transactions.length} transactions from Firebase');
      
      print('Data loaded successfully from Firebase');
      print('Total money: $totalMoney');
      print('Total available: $totalAvailable');
      
      notifyListeners();
    } catch (e) {
      print('Error loading data from Firebase: $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Add income to a specific account
  Future<void> addIncomeToAccount(String categoryId, double amount, String description) async {
    print('Adding income to account: $categoryId, amount: $amount, description: $description');
    
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      final oldBalance = _categories[categoryIndex].currentBalance;
      final newBalance = oldBalance + amount;
      
      print('Category: ${_categories[categoryIndex].name}');
      print('Old balance: $oldBalance');
      print('New balance: $newBalance');
      
      _categories[categoryIndex] = BudgetCategory(
        id: _categories[categoryIndex].id,
        name: _categories[categoryIndex].name,
        allocatedAmount: _categories[categoryIndex].allocatedAmount,
        spentAmount: _categories[categoryIndex].spentAmount,
        currentBalance: newBalance,
        color: _categories[categoryIndex].color,
      );
      
      // Save updated category to Firebase
      await FirebaseService.updateCategory(_categories[categoryIndex]);
    } else {
      print('Category not found: $categoryId');
    }

    // Add income transaction
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: categoryId,
      description: description,
      amount: amount,
      date: DateTime.now(),
      isExpense: false,
      categoryName: categoryIndex != -1 ? _categories[categoryIndex].name : 'Unknown',
    );
    _transactions.add(transaction);

    // Save transaction to Firebase
    await FirebaseService.saveTransaction(transaction);

    print('Transaction added: ${transaction.id}');
    print('Total transactions: ${_transactions.length}');
    print('Data saved to Firebase');

    notifyListeners();
  }

  // Add expense to a specific account
  Future<void> addExpenseToAccount(String categoryId, double amount, String description) async {
    print('Adding expense to account: $categoryId, amount: $amount, description: $description');
    
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      final oldSpent = _categories[categoryIndex].spentAmount;
      final newSpent = oldSpent + amount;
      final oldBalance = _categories[categoryIndex].currentBalance;
      final newBalance = oldBalance - amount; // Reduce the balance when spending
      
      print('Category: ${_categories[categoryIndex].name}');
      print('Old spent: $oldSpent');
      print('New spent: $newSpent');
      print('Old balance: $oldBalance');
      print('New balance: $newBalance');
      
      _categories[categoryIndex] = BudgetCategory(
        id: _categories[categoryIndex].id,
        name: _categories[categoryIndex].name,
        allocatedAmount: _categories[categoryIndex].allocatedAmount,
        spentAmount: newSpent,
        currentBalance: newBalance, // Update the balance
        color: _categories[categoryIndex].color,
      );
      
      // Save updated category to Firebase
      await FirebaseService.updateCategory(_categories[categoryIndex]);
    } else {
      print('Category not found: $categoryId');
    }

    // Add expense transaction
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: categoryId,
      description: description,
      amount: amount,
      date: DateTime.now(),
      isExpense: true,
      categoryName: categoryIndex != -1 ? _categories[categoryIndex].name : 'Unknown',
    );
    _transactions.add(transaction);

    // Save transaction to Firebase
    await FirebaseService.saveTransaction(transaction);

    print('Transaction added: ${transaction.id}');
    print('Total transactions: ${_transactions.length}');
    print('Data saved to Firebase');

    notifyListeners();
  }

  // Legacy method for backward compatibility
  Future<void> addIncome(double amount, Map<String, double> allocations) async {
    _totalIncome += amount;
    
    // Update category allocations
    for (var entry in allocations.entries) {
      final categoryIndex = _categories.indexWhere((c) => c.id == entry.key);
      if (categoryIndex != -1) {
        _categories[categoryIndex] = BudgetCategory(
          id: _categories[categoryIndex].id,
          name: _categories[categoryIndex].name,
          allocatedAmount: _categories[categoryIndex].allocatedAmount + entry.value,
          spentAmount: _categories[categoryIndex].spentAmount,
          currentBalance: _categories[categoryIndex].currentBalance + entry.value,
          color: _categories[categoryIndex].color,
        );
        
        // Save updated category to Firebase
        await FirebaseService.updateCategory(_categories[categoryIndex]);
      }
    }

    // Add income transaction
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: 'income',
      description: 'Income Entry',
      amount: amount,
      date: DateTime.now(),
      isExpense: false,
      categoryName: 'Income',
    );
    _transactions.add(transaction);

    // Save transaction to Firebase
    await FirebaseService.saveTransaction(transaction);

    notifyListeners();
  }

  // Legacy method for backward compatibility
  Future<void> addExpense(String categoryId, String description, double amount) async {
    await addExpenseToAccount(categoryId, amount, description);
  }

  Future<void> addCategory(String name, double allocatedAmount, Color color) async {
    final category = BudgetCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      allocatedAmount: allocatedAmount,
      currentBalance: allocatedAmount,
      color: color,
    );
    _categories.add(category);
    
    // Save new category to Firebase
    await FirebaseService.saveCategory(category);
    
    notifyListeners();
  }

  Future<void> updateCategory(String id, String name, double allocatedAmount, Color color) async {
    print('Updating category: id=$id, name=$name, amount=$allocatedAmount');
    
    final categoryIndex = _categories.indexWhere((c) => c.id == id);
    if (categoryIndex != -1) {
      print('Found category at index $categoryIndex: ${_categories[categoryIndex].name}');
      print('Old name: ${_categories[categoryIndex].name}');
      print('New name: $name');
      
      _categories[categoryIndex] = BudgetCategory(
        id: id,
        name: name,
        allocatedAmount: allocatedAmount,
        spentAmount: _categories[categoryIndex].spentAmount,
        currentBalance: _categories[categoryIndex].currentBalance,
        color: color,
      );
      
      // Save updated category to Firebase
      await FirebaseService.updateCategory(_categories[categoryIndex]);
      
      print('Category updated in Firebase');
      notifyListeners();
    } else {
      print('Category not found with id: $id');
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    
    // Delete category from Firebase
    await FirebaseService.deleteCategory(id);
    
    notifyListeners();
  }

  List<TransactionModel> getTransactionsForCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    final sortedTransactions = List<TransactionModel>.from(_transactions);
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));
    return sortedTransactions.take(limit).toList();
  }

  // Get all transactions sorted by date (newest first)
  List<TransactionModel> getAllTransactions() {
    final sortedTransactions = List<TransactionModel>.from(_transactions);
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));
    return sortedTransactions;
  }
} 