import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/app_provider.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collections
  static const String _categoriesCollection = 'categories';
  static const String _transactionsCollection = 'transactions';

  // Get current user ID
  static String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Test Firebase connection
  static Future<bool> testFirebaseConnection() async {
    try {
      print('Testing Firebase connection...');
      
      // Check if Firebase is initialized
      if (!Firebase.apps.isNotEmpty) {
        print('Firebase is not initialized');
        return false;
      }
      
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('test').get();
      print('Firestore connection successful');
      
      // Test Auth connection
      final auth = FirebaseAuth.instance;
      print('Firebase Auth initialized successfully');
      
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
  
  static Future<void> initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        print('Firebase initialized successfully');
      } else {
        print('Firebase already initialized');
      }
    } catch (e) {
      print('Firebase initialization failed: $e');
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  // Categories Operations
  static Future<List<BudgetCategory>> getCategories(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId)
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

  static Future<void> saveCategory(BudgetCategory category, String projectId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId)
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

  static Future<void> updateCategory(BudgetCategory category, String projectId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId)
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

  static Future<void> deleteCategory(String categoryId, String projectId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId)
          .collection(_categoriesCollection)
          .doc(categoryId)
          .delete();
      print('Category deleted successfully: $categoryId');
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  // Transactions Operations
  static Future<List<TransactionModel>> getTransactions(String projectId) async {
    try {
      print('🔥 Getting transactions for project: $projectId');
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId)
          .collection(_transactionsCollection)
          .orderBy('date', descending: true)
          .get();
      
      print('🔥 Found ${snapshot.docs.length} transaction documents');
      
      List<TransactionModel> transactions = [];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('🔥 Processing transaction doc: ${doc.id}');
          print('🔥 Raw data: $data');
          
          // Handle different date formats
          DateTime transactionDate;
          if (data['date'] is Timestamp) {
            transactionDate = (data['date'] as Timestamp).toDate();
          } else if (data['date'] is String) {
            transactionDate = DateTime.parse(data['date'] as String);
          } else {
            print('🔥 Warning: Unknown date format, using current time');
            transactionDate = DateTime.now();
          }
          
          final transaction = TransactionModel(
            id: doc.id,
            categoryId: data['categoryId'] ?? '',
            description: data['description'] ?? '',
            amount: (data['amount'] ?? 0).toDouble(),
            date: transactionDate,
            isExpense: data['isExpense'] ?? false,
            categoryName: data['categoryName'] ?? '',
          );
          
          transactions.add(transaction);
          print('🔥 Successfully parsed transaction: ${transaction.description}');
        } catch (e) {
          print('🔥 Error parsing individual transaction ${doc.id}: $e');
          continue; // Skip this transaction but continue with others
        }
      }
      
      print('🔥 Successfully loaded ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      print('🔥 Error getting transactions: $e');
      print('🔥 Error type: ${e.runtimeType}');
      return [];
    }
  }

  static Future<void> saveTransaction(TransactionModel transaction, String projectId) async {
    try {
      print('🔥 FirebaseService: Attempting to save transaction...');
      print('🔥 Current User ID: $_currentUserId');
      print('🔥 Project ID: $projectId');
      print('🔥 Transaction Details: ${transaction.description} - ${transaction.amount}');
      
      final docRef = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId)
          .collection(_transactionsCollection)
          .add({
        'categoryId': transaction.categoryId,
        'description': transaction.description,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'isExpense': transaction.isExpense,
        'categoryName': transaction.categoryName,
      });
      print('🔥 Transaction saved successfully with ID: ${docRef.id}');
      print('🔥 Transaction description: ${transaction.description}');
    } catch (e) {
      print('🔥 Error saving transaction: $e');
      print('🔥 Error details: ${e.toString()}');
      rethrow; // Re-throw the error so it can be caught by the caller
    }
  }

  // Initialize default categories if none exist
  static Future<void> initializeDefaultCategories(String projectId) async {
    try {
      final categories = await getCategories(projectId);
      if (categories.isEmpty) {
        print('No categories found, initializing defaults...');
        
        final defaultCategories = [
          BudgetCategory(
            id: '1',
            name: 'Fuel',
            allocatedAmount: 0,
            currentBalance: 0,
            color: Colors.orange,
          ),
          BudgetCategory(
            id: '2',
            name: 'food',
            allocatedAmount: 0,
            currentBalance: 0,
            color: Colors.green,
          ),
          BudgetCategory(
            id: '3',
            name: 'Rent',
            allocatedAmount: 0,
            currentBalance: 0,
            color: Colors.blue,
          ),
        ];

        for (var category in defaultCategories) {
          await saveCategory(category, projectId);
        }
        print('Default categories initialized');
      }
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }
} 