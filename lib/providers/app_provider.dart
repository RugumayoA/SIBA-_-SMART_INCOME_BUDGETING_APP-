import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/project_service.dart';
import '../services/auth_service.dart';
import '../models/project.dart';


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

  double get remainingAmount => currentBalance;
  double get spentPercentage => (allocatedAmount + spentAmount) > 0 ? (spentAmount / (allocatedAmount + spentAmount)) * 100 : 0;

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
  Project? _currentProject;
  List<Project> _projects = [];

  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  Project? get currentProject => _currentProject;
  List<Project> get projects => _projects;
  int get selectedIndex => _selectedIndex;
  List<BudgetCategory> get categories => _categories;
  List<TransactionModel> get transactions => _transactions;
  double get totalIncome => _totalIncome;

  // Total money across all accounts (current balance)
  double get totalMoney => _categories.fold(0.0, (sum, category) => sum + category.currentBalance);
  
  // Total spent across all accounts
  double get totalSpent => _categories.fold(0.0, (sum, category) => sum + category.spentAmount);
  
  // Total available money (same as total money since currentBalance already accounts for spending)
  double get totalAvailable => totalMoney;

  AppProvider() {
    print('AppProvider constructor called');
    // Listen to authentication state changes
    AuthService.authStateChanges.listen((User? user) {
      if (user != null) {
        // User is authenticated, load data
        print('🔐 User authenticated: ${user.email}, loading data...');
        _loadData();
      } else {
        // User is not authenticated, clear data
        print('🚪 User not authenticated, clearing data...');
        _clearData();
      }
    });
  }

  void _clearData() {
    _categories.clear();
    _transactions.clear();
    _projects.clear();
    _currentProject = null;
    _totalIncome = 0.0;
    print('Data cleared');
    notifyListeners();
  }

  Future<void> _loadData() async {
    try {
      print('📦 Loading data from Firebase...');
      print('📦 Current user: ${AuthService.currentUser?.email ?? "None"}');
      
      // Load projects first
      _projects = await ProjectService.getProjects();
      print('📦 Loaded ${_projects.length} projects from Firebase');
      
      // If no projects exist, create a default project
      if (_projects.isEmpty) {
        var defaultProject = Project(
          id: '',
          name: 'Default Project',
          description: 'My first budget project',
          createdAt: DateTime.now(),
          color: Colors.blue,
          totalBudget: 0,
          currentBalance: 0,
        );
        
        final projectId = await ProjectService.createProject(defaultProject);
        if (projectId != null) {
          defaultProject = defaultProject.copyWith(id: projectId);
          _projects.add(defaultProject);
          _currentProject = defaultProject;
        }
      } else {
        // Select the first project as current
        _currentProject = _projects.first;
      }
      
      if (_currentProject != null) {
        // Initialize default categories if needed
        await FirebaseService.initializeDefaultCategories(_currentProject!.id);
        
        // Load categories from Firebase
        _categories = await FirebaseService.getCategories(_currentProject!.id);
        print('Loaded ${_categories.length} categories from Firebase');
        for (var category in _categories) {
          print('  - ${category.name} (ID: ${category.id}): Balance=${category.currentBalance}');
        }
        
        // Load transactions from Firebase
        _transactions = await FirebaseService.getTransactions(_currentProject!.id);
        print('📦 Loaded ${_transactions.length} transactions from Firebase');
        for (var transaction in _transactions) {
          print('  📄 Transaction: ${transaction.description} - ${transaction.amount} (${transaction.isExpense ? "Expense" : "Income"})');
        }
        
        // Update project budget to sync with category totals
        await _updateProjectBudgetFromCategories();
      }
      
      print('Data loaded successfully from Firebase');
      print('Total money: $totalMoney');
      print('Total available: $totalAvailable');
      
      notifyListeners();
    } catch (e) {
      print('Error loading data from Firebase: $e');
    }
  }

  // Public method to reload data
  Future<void> reloadData() async {
    if (AuthService.currentUser != null) {
      print('Manually reloading data...');
      await _loadData();
    } else {
      print('Cannot reload data: User not authenticated');
    }
  }

  // Public method to fix budget display for existing projects
  Future<void> fixAllProjectBudgets() async {
    print('🔧 Fixing all project budgets...');
    
    for (var project in _projects) {
      // Select each project temporarily to calculate its budget
      final originalProject = _currentProject;
      
      _currentProject = project;
      _categories = await FirebaseService.getCategories(project.id);
      await _updateProjectBudgetFromCategories();
      
      // Restore original current project
      _currentProject = originalProject;
      if (_currentProject != null) {
        _categories = await FirebaseService.getCategories(_currentProject!.id);
      }
    }
    
    print('✅ All project budgets fixed');
    notifyListeners();
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
        allocatedAmount: newBalance, // Update allocated amount to reflect current status
        spentAmount: _categories[categoryIndex].spentAmount,
        currentBalance: newBalance,
        color: _categories[categoryIndex].color,
      );
      
      // Save updated category to Firebase
      if (_currentProject != null) {
        await FirebaseService.updateCategory(_categories[categoryIndex], _currentProject!.id);
      }
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
    if (_currentProject != null) {
      print('💾 Saving INCOME transaction to Firebase...');
      print('  💾 Project ID: ${_currentProject!.id}');
      print('  💾 Transaction: ${transaction.description} - ${transaction.amount}');
      await FirebaseService.saveTransaction(transaction, _currentProject!.id);
      print('💾 INCOME transaction saved to Firebase successfully');
    } else {
      print('❌ No current project found, cannot save INCOME transaction');
    }

    // Update project budget and balance
    await _updateProjectBudgetFromCategories();

    print('📊 INCOME Transaction added: ${transaction.id}');
    print('📊 Total transactions: ${_transactions.length}');
    print('📊 Data saved to Firebase');

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
        allocatedAmount: newBalance, // Update allocated amount to reflect current status
        spentAmount: newSpent,
        currentBalance: newBalance, // Update the balance
        color: _categories[categoryIndex].color,
      );
      
      // Save updated category to Firebase
      if (_currentProject != null) {
        await FirebaseService.updateCategory(_categories[categoryIndex], _currentProject!.id);
      }
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
    if (_currentProject != null) {
      print('💾 Saving EXPENSE transaction to Firebase...');
      print('  💾 Project ID: ${_currentProject!.id}');
      print('  💾 Transaction: ${transaction.description} - ${transaction.amount}');
      await FirebaseService.saveTransaction(transaction, _currentProject!.id);
      print('💾 EXPENSE transaction saved to Firebase successfully');
    } else {
      print('❌ No current project found, cannot save EXPENSE transaction');
    }

    // Update project budget and balance
    await _updateProjectBudgetFromCategories();

    print('📊 EXPENSE Transaction added: ${transaction.id}');
    print('📊 Total transactions: ${_transactions.length}');
    print('📊 Data saved to Firebase');

    notifyListeners();
  }

  // Legacy method for backward compatibility
  Future<void> addIncome(double amount, Map<String, double> allocations) async {
    _totalIncome += amount;
    
    // Update category allocations
    for (var entry in allocations.entries) {
      final categoryIndex = _categories.indexWhere((c) => c.id == entry.key);
      if (categoryIndex != -1) {
        final newBalance = _categories[categoryIndex].currentBalance + entry.value;
        _categories[categoryIndex] = BudgetCategory(
          id: _categories[categoryIndex].id,
          name: _categories[categoryIndex].name,
          allocatedAmount: newBalance, // Update allocated amount to reflect current status
          spentAmount: _categories[categoryIndex].spentAmount,
          currentBalance: newBalance,
          color: _categories[categoryIndex].color,
        );
        
        // Save updated category to Firebase
        if (_currentProject != null) {
          await FirebaseService.updateCategory(_categories[categoryIndex], _currentProject!.id);
        }
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
    if (_currentProject != null) {
      await FirebaseService.saveTransaction(transaction, _currentProject!.id);
    }

    // Update project budget and balance
    await _updateProjectBudgetFromCategories();

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
    if (_currentProject != null) {
      await FirebaseService.saveCategory(category, _currentProject!.id);
    }
    
    // Update project budget and balance
    await _updateProjectBudgetFromCategories();
    
    notifyListeners();
  }

  Future<void> updateCategory(String id, String name, double allocatedAmount, Color color) async {
    print('Updating category: id=$id, name=$name, amount=$allocatedAmount');
    
    final categoryIndex = _categories.indexWhere((c) => c.id == id);
    if (categoryIndex != -1) {
      print('Found category at index $categoryIndex: ${_categories[categoryIndex].name}');
      print('Old name: ${_categories[categoryIndex].name}');
      print('New name: $name');
      print('Old allocated amount: ${_categories[categoryIndex].allocatedAmount}');
      print('New allocated amount: $allocatedAmount');
      print('Old current balance: ${_categories[categoryIndex].currentBalance}');
      
      // The allocatedAmount parameter now represents the new current balance for the category
      print('Old current balance: ${_categories[categoryIndex].currentBalance}');
      print('New current balance: $allocatedAmount');
      
      _categories[categoryIndex] = BudgetCategory(
        id: id,
        name: name,
        allocatedAmount: allocatedAmount, // This now represents current balance
        spentAmount: _categories[categoryIndex].spentAmount,
        currentBalance: allocatedAmount, // Keep both values in sync
        color: color,
      );
      
      // Save updated category to Firebase
      if (_currentProject != null) {
        await FirebaseService.updateCategory(_categories[categoryIndex], _currentProject!.id);
      }
      
      // Update project budget and balance
      await _updateProjectBudgetFromCategories();
      
      print('Category updated in Firebase');
      print('Total money after update: $totalMoney');
      print('Total available after update: $totalAvailable');
      notifyListeners();
    } else {
      print('Category not found with id: $id');
    }
  }

  // Helper method to update project budget based on category totals
  Future<void> _updateProjectBudgetFromCategories() async {
    if (_currentProject == null) {
      print('❌ No current project to update');
      return;
    }

    // Calculate total budget from all category allocated amounts
    final calculatedTotalBudget = _categories.fold(0.0, (sum, category) => sum + category.allocatedAmount);
    
    // Calculate current balance from all category current balances
    final calculatedCurrentBalance = _categories.fold(0.0, (sum, category) => sum + category.currentBalance);
    
    print('🔄 Updating project budget:');
    print('  📊 Old total budget: ${_currentProject!.totalBudget}');
    print('  📊 New total budget: $calculatedTotalBudget');
    print('  📊 Old current balance: ${_currentProject!.currentBalance}');
    print('  📊 New current balance: $calculatedCurrentBalance');
    
    // Update current project with new values
    _currentProject = _currentProject!.copyWith(
      totalBudget: calculatedTotalBudget,
      currentBalance: calculatedCurrentBalance,
      lastModified: DateTime.now(),
    );
    
    // Update in projects list
    final projectIndex = _projects.indexWhere((p) => p.id == _currentProject!.id);
    if (projectIndex != -1) {
      _projects[projectIndex] = _currentProject!;
    }
    
    // Save updated project to Firebase
    try {
      await ProjectService.updateProject(_currentProject!);
      print('✅ Project budget updated in Firebase successfully');
    } catch (e) {
      print('❌ Error updating project budget in Firebase: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    
    // Delete category from Firebase
    if (_currentProject != null) {
      await FirebaseService.deleteCategory(id, _currentProject!.id);
    }
    
    // Update project budget and balance
    await _updateProjectBudgetFromCategories();
    
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

  // Project management methods
  Future<void> createProject(Project project) async {
    final projectId = await ProjectService.createProject(project);
    if (projectId != null) {
      final newProject = project.copyWith(id: projectId);
      _projects.add(newProject);
      _currentProject = newProject;
      notifyListeners();
    }
  }

  Future<void> selectProject(Project project) async {
    _currentProject = project;
    
    // Load categories and transactions for the selected project
    if (_currentProject != null) {
      _categories = await FirebaseService.getCategories(_currentProject!.id);
      _transactions = await FirebaseService.getTransactions(_currentProject!.id);
      
      // Update project budget to sync with category totals
      await _updateProjectBudgetFromCategories();
      
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    await ProjectService.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      if (_currentProject?.id == project.id) {
        _currentProject = project;
      }
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await ProjectService.deleteProject(projectId);
      
      // Only update local state if deletion was successful
      _projects.removeWhere((p) => p.id == projectId);
      
      // If we deleted the current project, switch to another one or null
      if (_currentProject?.id == projectId) {
        _currentProject = _projects.isNotEmpty ? _projects.first : null;
        
        // Clear categories and transactions if no current project
        if (_currentProject == null) {
          _categories.clear();
          _transactions.clear();
        } else {
          // Load data for the new current project
          await _loadData();
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error in deleteProject: $e');
      rethrow; // Rethrow to allow UI to handle the error
    }
  }
} 