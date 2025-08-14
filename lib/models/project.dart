import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'currency.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? lastModified;
  final Color color;
  final double totalBudget;
  final double currentBalance;
  final Currency currency;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.lastModified,
    required this.color,
    this.totalBudget = 0.0,
    this.currentBalance = 0.0,
    this.currency = Currencies.ugx,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'color': color.value,
      'totalBudget': totalBudget,
      'currentBalance': currentBalance,
      'currency': currency.toJson(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    // Handle different date formats for createdAt
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt'] as String);
    } else {
      createdAt = DateTime.now(); // Fallback
    }

    // Handle different date formats for lastModified
    DateTime? lastModified;
    if (json['lastModified'] is Timestamp) {
      lastModified = (json['lastModified'] as Timestamp).toDate();
    } else if (json['lastModified'] is String) {
      lastModified = DateTime.parse(json['lastModified'] as String);
    } else {
      lastModified = null;
    }

    // Handle currency
    Currency currency = Currencies.ugx; // Default to UGX for backward compatibility
    if (json['currency'] != null) {
      if (json['currency'] is Map) {
        currency = Currency.fromJson(json['currency']);
      } else if (json['currency'] is String) {
        // Handle legacy string format
        currency = Currencies.getByCode(json['currency']) ?? Currencies.ugx;
      }
    }

    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: createdAt,
      lastModified: lastModified,
      color: Color(json['color']),
      totalBudget: json['totalBudget']?.toDouble() ?? 0.0,
      currentBalance: json['currentBalance']?.toDouble() ?? 0.0,
      currency: currency,
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    Color? color,
    double? totalBudget,
    double? currentBalance,
    Currency? currency,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      color: color ?? this.color,
      totalBudget: totalBudget ?? this.totalBudget,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
    );
  }
} 