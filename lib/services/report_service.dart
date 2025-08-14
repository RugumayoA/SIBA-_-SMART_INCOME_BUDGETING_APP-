import 'package:flutter/material.dart';
import '../models/report.dart';
import '../providers/app_provider.dart';

class ReportService {
  static List<ExpenseIncomeData> generateExpenseIncomeReport(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date))
        .toList();

    final data = <ExpenseIncomeData>[];
    
    // Group by month for the given date range
    final Map<String, Map<String, double>> monthlyData = {};
    
    for (final transaction in transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      
      monthlyData[monthKey] ??= {'income': 0.0, 'expense': 0.0};
      
      if (transaction.isExpense) {
        monthlyData[monthKey]!['expense'] = 
            (monthlyData[monthKey]!['expense'] ?? 0) + transaction.amount;
      } else {
        monthlyData[monthKey]!['income'] = 
            (monthlyData[monthKey]!['income'] ?? 0) + transaction.amount;
      }
    }

    // Convert to ExpenseIncomeData list
    for (final entry in monthlyData.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0);
      
      data.add(ExpenseIncomeData(
        totalIncome: entry.value['income'] ?? 0,
        totalExpense: entry.value['expense'] ?? 0,
        dateRange: DateRange(startDate: monthStart, endDate: monthEnd),
      ));
    }

    // Sort by date
    data.sort((a, b) => a.dateRange.startDate.compareTo(b.dateRange.startDate));
    
    return data;
  }

  static List<CategorySpendingData> generateCategorySpendingReport(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date) && t.isExpense)
        .toList();

    final Map<String, CategorySpendingData> categoryMap = {};

    // Initialize with all categories
    for (final category in provider.categories) {
      categoryMap[category.id] = CategorySpendingData(
        categoryId: category.id,
        categoryName: category.name,
        categoryColor: category.color,
        totalSpent: 0.0,
        budgetAllocated: category.allocatedAmount,
        transactionCount: 0,
      );
    }

    // Aggregate spending by category
    for (final transaction in transactions) {
      if (categoryMap.containsKey(transaction.categoryId)) {
        final existing = categoryMap[transaction.categoryId]!;
        categoryMap[transaction.categoryId] = CategorySpendingData(
          categoryId: existing.categoryId,
          categoryName: existing.categoryName,
          categoryColor: existing.categoryColor,
          totalSpent: existing.totalSpent + transaction.amount,
          budgetAllocated: existing.budgetAllocated,
          transactionCount: existing.transactionCount + 1,
        );
      }
    }

    // Return only categories with spending, sorted by amount
    final result = categoryMap.values
        .where((data) => data.totalSpent > 0)
        .toList();
    
    result.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    
    return result;
  }

  static List<TimeSeriesData> generateTimeSeriesData(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date))
        .toList();

    final Map<DateTime, Map<String, double>> dailyData = {};
    
    // Initialize all dates in range
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final dateKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
      dailyData[dateKey] = {'income': 0.0, 'expense': 0.0};
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Aggregate transactions by day
    for (final transaction in transactions) {
      final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      
      if (dailyData.containsKey(dateKey)) {
        if (transaction.isExpense) {
          dailyData[dateKey]!['expense'] = 
              (dailyData[dateKey]!['expense'] ?? 0) + transaction.amount;
        } else {
          dailyData[dateKey]!['income'] = 
              (dailyData[dateKey]!['income'] ?? 0) + transaction.amount;
        }
      }
    }

    // Convert to TimeSeriesData with running balance
    final result = <TimeSeriesData>[];
    double runningBalance = 0.0;

    final sortedDates = dailyData.keys.toList()..sort();
    
    for (final date in sortedDates) {
      final dayData = dailyData[date]!;
      final income = dayData['income'] ?? 0;
      final expense = dayData['expense'] ?? 0;
      
      runningBalance += (income - expense);
      
      result.add(TimeSeriesData(
        date: date,
        income: income,
        expense: expense,
        balance: runningBalance,
      ));
    }

    return result;
  }

  static List<MonthlyData> generateMonthlyReport(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date))
        .toList();

    final Map<String, MonthlyData> monthlyMap = {};

    for (final transaction in transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      
      if (!monthlyMap.containsKey(monthKey)) {
        monthlyMap[monthKey] = MonthlyData(
          month: transaction.date.month,
          year: transaction.date.year,
          totalIncome: 0.0,
          totalExpense: 0.0,
        );
      }

      final existing = monthlyMap[monthKey]!;
      
      if (transaction.isExpense) {
        monthlyMap[monthKey] = MonthlyData(
          month: existing.month,
          year: existing.year,
          totalIncome: existing.totalIncome,
          totalExpense: existing.totalExpense + transaction.amount,
        );
      } else {
        monthlyMap[monthKey] = MonthlyData(
          month: existing.month,
          year: existing.year,
          totalIncome: existing.totalIncome + transaction.amount,
          totalExpense: existing.totalExpense,
        );
      }
    }

    final result = monthlyMap.values.toList();
    result.sort((a, b) {
      final dateA = DateTime(a.year, a.month);
      final dateB = DateTime(b.year, b.month);
      return dateA.compareTo(dateB);
    });

    return result;
  }

  static List<WeeklyData> generateWeeklyReport(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date))
        .toList();

    final Map<DateTime, WeeklyData> weeklyMap = {};

    for (final transaction in transactions) {
      // Get start of week (Monday)
      final weekStart = transaction.date.subtract(
        Duration(days: transaction.date.weekday - 1),
      );
      final weekKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
      
      if (!weeklyMap.containsKey(weekKey)) {
        weeklyMap[weekKey] = WeeklyData(
          weekStart: weekKey,
          totalIncome: 0.0,
          totalExpense: 0.0,
        );
      }

      final existing = weeklyMap[weekKey]!;
      
      if (transaction.isExpense) {
        weeklyMap[weekKey] = WeeklyData(
          weekStart: existing.weekStart,
          totalIncome: existing.totalIncome,
          totalExpense: existing.totalExpense + transaction.amount,
        );
      } else {
        weeklyMap[weekKey] = WeeklyData(
          weekStart: existing.weekStart,
          totalIncome: existing.totalIncome + transaction.amount,
          totalExpense: existing.totalExpense,
        );
      }
    }

    final result = weeklyMap.values.toList();
    result.sort((a, b) => a.weekStart.compareTo(b.weekStart));

    return result;
  }

  static List<BudgetUtilizationData> generateBudgetUtilizationReport(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date) && t.isExpense)
        .toList();

    final Map<String, double> categorySpending = {};

    // Calculate spending by category
    for (final transaction in transactions) {
      categorySpending[transaction.categoryId] = 
          (categorySpending[transaction.categoryId] ?? 0) + transaction.amount;
    }

    // Generate utilization data for all categories
    final result = <BudgetUtilizationData>[];
    
    for (final category in provider.categories) {
      final spentAmount = categorySpending[category.id] ?? 0.0;
      
      result.add(BudgetUtilizationData(
        categoryId: category.id,
        categoryName: category.name,
        categoryColor: category.color,
        budgetAmount: category.allocatedAmount,
        spentAmount: spentAmount,
      ));
    }

    // Sort by utilization percentage (highest first)
    result.sort((a, b) => b.utilizationPercentage.compareTo(a.utilizationPercentage));

    return result;
  }

  static ExpenseIncomeData getTotalSummary(
    AppProvider provider,
    DateRange dateRange,
  ) {
    final transactions = provider.getAllTransactions()
        .where((t) => dateRange.contains(t.date))
        .toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final transaction in transactions) {
      if (transaction.isExpense) {
        totalExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    return ExpenseIncomeData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      dateRange: dateRange,
    );
  }

  static List<CategorySpendingData> getTopSpendingCategories(
    AppProvider provider,
    DateRange dateRange, {
    int limit = 5,
  }) {
    final categoryData = generateCategorySpendingReport(provider, dateRange);
    return categoryData.take(limit).toList();
  }

  static ReportSummary generateReportSummary(
    AppProvider provider,
    ReportType type,
    DateRange dateRange,
  ) {
    switch (type) {
      case ReportType.expenseVsIncome:
        final summary = getTotalSummary(provider, dateRange);
        return ReportSummary(
          type: type,
          dateRange: dateRange,
          data: {
            'totalIncome': summary.totalIncome,
            'totalExpense': summary.totalExpense,
            'netAmount': summary.netAmount,
          },
          title: 'Income vs Expenses',
          subtitle: dateRange.displayName,
        );

      case ReportType.categoryBreakdown:
        final categories = generateCategorySpendingReport(provider, dateRange);
        final totalSpent = categories.fold(0.0, (sum, cat) => sum + cat.totalSpent);
        return ReportSummary(
          type: type,
          dateRange: dateRange,
          data: {
            'categoriesCount': categories.length,
            'totalSpent': totalSpent,
            'topCategory': categories.isNotEmpty ? categories.first.categoryName : 'None',
          },
          title: 'Category Breakdown',
          subtitle: '${categories.length} categories with spending',
        );

      case ReportType.budgetUtilization:
        final budgetData = generateBudgetUtilizationReport(provider, dateRange);
        final overBudgetCount = budgetData.where((b) => b.isOverBudget).length;
        return ReportSummary(
          type: type,
          dateRange: dateRange,
          data: {
            'totalCategories': budgetData.length,
            'overBudgetCount': overBudgetCount,
            'avgUtilization': budgetData.isNotEmpty 
                ? budgetData.fold(0.0, (sum, b) => sum + b.utilizationPercentage) / budgetData.length
                : 0.0,
          },
          title: 'Budget Utilization',
          subtitle: '$overBudgetCount categories over budget',
        );

      default:
        return ReportSummary(
          type: type,
          dateRange: dateRange,
          data: {},
          title: 'Report',
          subtitle: dateRange.displayName,
        );
    }
  }
}

