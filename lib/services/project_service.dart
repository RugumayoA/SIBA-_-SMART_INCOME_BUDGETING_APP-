import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';

class ProjectService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Get all projects for current user
  static Future<List<Project>> getProjects() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Project.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error getting projects: $e');
      return [];
    }
  }

  // Create new project
  static Future<String?> createProject(Project project) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .add({
        'name': project.name,
        'description': project.description,
        'createdAt': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        'color': project.color.value,
        'totalBudget': project.totalBudget,
        'currentBalance': project.currentBalance,
        'currency': project.currency.toJson(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating project: $e');
      return null;
    }
  }

  // Update project
  static Future<void> updateProject(Project project) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(project.id)
          .update({
        'name': project.name,
        'description': project.description,
        'lastModified': FieldValue.serverTimestamp(),
        'color': project.color.value,
        'totalBudget': project.totalBudget,
        'currentBalance': project.currentBalance,
        'currency': project.currency.toJson(),
      });
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  // Delete project
  static Future<void> deleteProject(String projectId) async {
    try {
      final projectRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('projects')
          .doc(projectId);

      // Delete all transactions in this project FIRST
      final transactionsSnapshot = await projectRef
          .collection('transactions')
          .get();

      for (var doc in transactionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all categories in this project SECOND
      final categoriesSnapshot = await projectRef
          .collection('categories')
          .get();

      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete project document LAST
      await projectRef.delete();
      
      print('Project $projectId deleted successfully');
    } catch (e) {
      print('Error deleting project: $e');
      rethrow; // Rethrow to allow proper error handling upstream
    }
  }
} 