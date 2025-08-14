import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportData {
  final String id;
  final DateTime generatedAt;
  final String projectId;
  final DateRange dateRange;

  ReportData({
    required this.id,
    required this.generatedAt,
    required this.projectId,
    required this.dateRange,
  });
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });

  bool contains(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(endDate.add(const Duration(days: 1)));
  }

  String get displayName {
    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  static DateRange thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateRange(startDate: startOfMonth, endDate: endOfMonth);
  }

  static DateRange lastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);
    return DateRange(startDate: lastMonth, endDate: endOfLastMonth);
  }

  static DateRange thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return DateRange(startDate: startOfWeek, endDate: endOfWeek);
  }

  static DateRange last30Days() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return DateRange(startDate: thirtyDaysAgo, endDate: now);
  }

  static DateRange thisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    return DateRange(startDate: startOfYear, endDate: endOfYear);
  }
}

class ExpenseIncomeData {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final DateRange dateRange;

  ExpenseIncomeData({
    required this.totalIncome,
    required this.totalExpense,
    required this.dateRange,
  }) : netAmount = totalIncome - totalExpense;

  double get expensePercentage {
    if (totalIncome == 0) return 0;
    return (totalExpense / totalIncome) * 100;
  }
}

class CategorySpendingData {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;
  final double totalSpent;
  final double budgetAllocated;
  final int transactionCount;

  CategorySpendingData({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.totalSpent,
    required this.budgetAllocated,
    required this.transactionCount,
  });

  double get utilizationPercentage {
    if (budgetAllocated == 0) return 0;
    return (totalSpent / budgetAllocated) * 100;
  }

  double get remainingBudget => budgetAllocated - totalSpent;
}

class TimeSeriesData {
  final DateTime date;
  final double income;
  final double expense;
  final double balance;

  TimeSeriesData({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });

  double get netFlow => income - expense;
}

class MonthlyData {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  MonthlyData({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
  }) : netAmount = totalIncome - totalExpense;

  String get monthName => DateFormat('MMM').format(DateTime(year, month));
  String get displayName => '$monthName $year';
}

class WeeklyData {
  final DateTime weekStart;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  WeeklyData({
    required this.weekStart,
    required this.totalIncome,
    required this.totalExpense,
  }) : netAmount = totalIncome - totalExpense;

  String get displayName {
    final formatter = DateFormat('MMM d');
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }
}

class BudgetUtilizationData {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;
  final double budgetAmount;
  final double spentAmount;
  final double utilizationPercentage;

  BudgetUtilizationData({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.budgetAmount,
    required this.spentAmount,
  }) : utilizationPercentage = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;

  double get remainingAmount => budgetAmount - spentAmount;
  bool get isOverBudget => spentAmount > budgetAmount;
  bool get isNearBudgetLimit => utilizationPercentage > 80;
}

enum ReportType {
  expenseVsIncome,
  categoryBreakdown,
  timeSeriesAnalysis,
  budgetUtilization,
  topSpendingCategories,
  monthlyTrends,
  weeklyTrends,
}

class ReportSummary {
  final ReportType type;
  final DateRange dateRange;
  final Map<String, dynamic> data;
  final String title;
  final String subtitle;

  ReportSummary({
    required this.type,
    required this.dateRange,
    required this.data,
    required this.title,
    required this.subtitle,
  });
}

