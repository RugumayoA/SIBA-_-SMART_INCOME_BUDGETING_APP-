import 'package:flutter/material.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? lastModified;
  final Color color;
  final double totalBudget;
  final double currentBalance;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.lastModified,
    required this.color,
    this.totalBudget = 0.0,
    this.currentBalance = 0.0,
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
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null 
          ? DateTime.parse(json['lastModified']) 
          : null,
      color: Color(json['color']),
      totalBudget: json['totalBudget']?.toDouble() ?? 0.0,
      currentBalance: json['currentBalance']?.toDouble() ?? 0.0,
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
    );
  }
} 