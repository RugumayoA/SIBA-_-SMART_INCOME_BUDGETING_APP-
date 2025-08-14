import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../utils/currency_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateRange _selectedDateRange = DateRange.thisMonth();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<DateRange>(
            icon: const Icon(Icons.date_range),
            onSelected: (DateRange range) {
              setState(() {
                _selectedDateRange = range;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: DateRange.thisMonth(),
                child: const Text('This Month'),
              ),
              PopupMenuItem(
                value: DateRange.lastMonth(),
                child: const Text('Last Month'),
              ),
              PopupMenuItem(
                value: DateRange.last30Days(),
                child: const Text('Last 30 Days'),
              ),
              PopupMenuItem(
                value: DateRange.thisYear(),
                child: const Text('This Year'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 16)),
            Tab(text: 'Categories', icon: Icon(Icons.pie_chart, size: 16)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up, size: 16)),
            Tab(text: 'Budget', icon: Icon(Icons.account_balance_wallet, size: 16)),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Data Available',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some transactions to see reports and analytics',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider),
              _buildCategoriesTab(provider),
              _buildTrendsTab(provider),
              _buildBudgetTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AppProvider provider) {
    final summary = ReportService.getTotalSummary(provider, _selectedDateRange);
    final currency = provider.currentProject?.currency;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Period',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _selectedDateRange.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  currency != null 
                    ? CurrencyFormatter.formatCurrency(summary.totalIncome, currency)
                    : CurrencyFormatter.formatUGX(summary.totalIncome),
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  currency != null 
                    ? CurrencyFormatter.formatCurrency(summary.totalExpense, currency)
                    : CurrencyFormatter.formatUGX(summary.totalExpense),
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Net Amount',
                  currency != null 
                    ? CurrencyFormatter.formatCurrency(summary.netAmount, currency)
                    : CurrencyFormatter.formatUGX(summary.netAmount),
                  summary.netAmount >= 0 ? Colors.green : Colors.red,
                  summary.netAmount >= 0 ? Icons.add : Icons.remove,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Expense Ratio',
                  '${summary.expensePercentage.toStringAsFixed(1)}%',
                  Colors.orange,
                  Icons.pie_chart,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Income vs Expense Chart
          const Text(
            'Income vs Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildIncomeExpenseChart(provider),
          ),

          const SizedBox(height: 24),

          // Top Categories
          const Text(
            'Top Spending Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          ..._buildTopCategoriesList(provider),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(AppProvider provider) {
    final categoryData = ReportService.generateCategorySpendingReport(provider, _selectedDateRange);
    final currency = provider.currentProject?.currency;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (categoryData.isNotEmpty) ...[
            // Pie Chart
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildCategoryPieChart(categoryData),
            ),

            const SizedBox(height: 24),

            // Category List
            ...categoryData.map((category) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category.categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.categoryName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${category.transactionCount} transactions',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency != null 
                          ? CurrencyFormatter.formatCurrency(category.totalSpent, currency)
                          : CurrencyFormatter.formatUGX(category.totalSpent),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${category.utilizationPercentage.toStringAsFixed(1)}% of budget',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No category spending data',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendsTab(AppProvider provider) {
    final monthlyData = ReportService.generateMonthlyReport(provider, _selectedDateRange);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (monthlyData.isNotEmpty) ...[
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildMonthlyTrendsChart(monthlyData),
            ),

            const SizedBox(height: 24),

            // Monthly Data List
            ...monthlyData.map((data) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      data.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Net: ${provider.currentProject?.currency != null 
                          ? CurrencyFormatter.formatCurrency(data.netAmount, provider.currentProject!.currency)
                          : CurrencyFormatter.formatUGX(data.netAmount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data.netAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'Income: ${provider.currentProject?.currency != null 
                          ? CurrencyFormatter.formatCurrency(data.totalIncome, provider.currentProject!.currency)
                          : CurrencyFormatter.formatUGX(data.totalIncome)}',
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      Text(
                        'Expense: ${provider.currentProject?.currency != null 
                          ? CurrencyFormatter.formatCurrency(data.totalExpense, provider.currentProject!.currency)
                          : CurrencyFormatter.formatUGX(data.totalExpense)}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.trending_up, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No trend data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetTab(AppProvider provider) {
    final budgetData = ReportService.generateBudgetUtilizationReport(provider, _selectedDateRange);
    final currency = provider.currentProject?.currency;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Utilization',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...budgetData.map((budget) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: budget.categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        budget.categoryName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${budget.utilizationPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: budget.isOverBudget 
                            ? Colors.red 
                            : budget.isNearBudgetLimit 
                                ? Colors.orange 
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: (budget.utilizationPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    budget.isOverBudget 
                        ? Colors.red 
                        : budget.isNearBudgetLimit 
                            ? Colors.orange 
                            : Colors.green,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: ${currency != null 
                        ? CurrencyFormatter.formatCurrency(budget.spentAmount, currency)
                        : CurrencyFormatter.formatUGX(budget.spentAmount)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Budget: ${currency != null 
                        ? CurrencyFormatter.formatCurrency(budget.budgetAmount, currency)
                        : CurrencyFormatter.formatUGX(budget.budgetAmount)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                
                if (budget.isOverBudget) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Over budget by ${currency != null 
                      ? CurrencyFormatter.formatCurrency(budget.spentAmount - budget.budgetAmount, currency)
                      : CurrencyFormatter.formatUGX(budget.spentAmount - budget.budgetAmount)}',
                    style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(AppProvider provider) {
    final expenseIncomeData = ReportService.generateExpenseIncomeReport(provider, _selectedDateRange);
    
    if (expenseIncomeData.isEmpty) {
      return const Center(
        child: Text('No data available', style: TextStyle(color: Colors.grey)),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: expenseIncomeData.map((e) => e.totalIncome > e.totalExpense ? e.totalIncome : e.totalExpense).fold(0.0, (prev, amount) => prev > amount ? prev : amount) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < expenseIncomeData.length) {
                  final data = expenseIncomeData[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM').format(data.dateRange.startDate),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: expenseIncomeData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalIncome,
                color: Colors.green,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: entry.value.totalExpense,
                color: Colors.red,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<CategorySpendingData> categoryData) {
    final total = categoryData.fold(0.0, (sum, cat) => sum + cat.totalSpent);
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categoryData.map((category) {
          final percentage = (category.totalSpent / total) * 100;
          return PieChartSectionData(
            color: category.categoryColor,
            value: category.totalSpent,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyTrendsChart(List<MonthlyData> monthlyData) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < monthlyData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      monthlyData[value.toInt()].monthName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.totalIncome);
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.totalExpense);
            }).toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopCategoriesList(AppProvider provider) {
    final topCategories = ReportService.getTopSpendingCategories(provider, _selectedDateRange, limit: 5);
    final currency = provider.currentProject?.currency;

    if (topCategories.isEmpty) {
      return [
        const Center(
          child: Text(
            'No spending data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }

    return topCategories.map((category) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: category.categoryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.categoryName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            currency != null 
              ? CurrencyFormatter.formatCurrency(category.totalSpent, currency)
              : CurrencyFormatter.formatUGX(category.totalSpent),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    )).toList();
  }
}
