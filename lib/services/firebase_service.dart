import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/app_provider.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  static const String _categoriesCollection = 'categories';
  static const String _transactionsCollection = 'transactions';
  static const String _usersCollection = 'users';

  // Get current user ID (for now, using a default user)
  static String get _currentUserId => 'default_user';

  // Categories Operations
  static Future<List<BudgetCategory>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_categoriesCollection)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BudgetCategory(
          id: doc.id,
          name: data['name'] ?? '',
          allocatedAmount: (data['allocatedAmount'] ?? 0).toDouble(),
          spentAmount: (data['spentAmount'] ?? 0).toDouble(),
          currentBalance: (data['currentBalance'] ?? 0).toDouble(),
          color: Color(data['color'] ?? Colors.grey.value),
        );
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  static Future<void> saveCategory(BudgetCategory category) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_categoriesCollection)
          .doc(category.id)
          .set({
        'name': category.name,
        'allocatedAmount': category.allocatedAmount,
        'spentAmount': category.spentAmount,
        'currentBalance': category.currentBalance,
        'color': category.color.value,
      });
      print('Category saved successfully: ${category.name}');
    } catch (e) {
      print('Error saving category: $e');
    }
  }

  static Future<void> updateCategory(BudgetCategory category) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_categoriesCollection)
          .doc(category.id)
          .update({
        'name': category.name,
        'allocatedAmount': category.allocatedAmount,
        'spentAmount': category.spentAmount,
        'currentBalance': category.currentBalance,
        'color': category.color.value,
      });
      print('Category updated successfully: ${category.name}');
    } catch (e) {
      print('Error updating category: $e');
    }
  }

  static Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_categoriesCollection)
          .doc(categoryId)
          .delete();
      print('Category deleted successfully: $categoryId');
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  // Transactions Operations
  static Future<List<TransactionModel>> getTransactions() async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_transactionsCollection)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel(
          id: doc.id,
          categoryId: data['categoryId'] ?? '',
          description: data['description'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          isExpense: data['isExpense'] ?? false,
          categoryName: data['categoryName'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  static Future<void> saveTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_transactionsCollection)
          .add({
        'categoryId': transaction.categoryId,
        'description': transaction.description,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'isExpense': transaction.isExpense,
        'categoryName': transaction.categoryName,
      });
      print('Transaction saved successfully: ${transaction.description}');
    } catch (e) {
      print('Error saving transaction: $e');
    }
  }

  // Initialize default categories if none exist
  static Future<void> initializeDefaultCategories() async {
    try {
      final categories = await getCategories();
      if (categories.isEmpty) {
        print('No categories found, initializing defaults...');
        
        final defaultCategories = [
          BudgetCategory(
            id: '1',
            name: 'Airtime',
            allocatedAmount: 200000,
            currentBalance: 200000,
            color: Colors.blue,
          ),
          BudgetCategory(
            id: '2',
            name: 'Food',
            allocatedAmount: 400000,
            currentBalance: 400000,
            color: Colors.green,
          ),
          BudgetCategory(
            id: '3',
            name: 'Clothes',
            allocatedAmount: 600000,
            currentBalance: 600000,
            color: Colors.orange,
          ),
          BudgetCategory(
            id: '4',
            name: 'Savings',
            allocatedAmount: 300000,
            currentBalance: 300000,
            color: Colors.purple,
          ),
        ];

        for (var category in defaultCategories) {
          await saveCategory(category);
        }
        print('Default categories initialized');
      }
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }
} 