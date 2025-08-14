import 'package:intl/intl.dart';
import '../models/currency.dart';

class CurrencyFormatter {
  // Legacy method for backward compatibility
  static String formatUGX(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return 'UGX ${formatter.format(amount)}';
  }
  
  // Format amount with specific currency
  static String formatCurrency(double amount, Currency currency) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${currency.symbol} ${formatter.format(amount)}';
  }
  
  // Format amount without currency symbol
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }
  
  // Format amount with currency code (e.g., "1,000 USD")
  static String formatWithCode(double amount, Currency currency) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)} ${currency.code}';
  }
  
  // Convert amount between currencies
  static double convertCurrency(double amount, Currency fromCurrency, Currency toCurrency) {
    if (fromCurrency.code == toCurrency.code) return amount;
    
    // Convert to USD first, then to target currency
    final usdAmount = amount / fromCurrency.exchangeRateToUSD;
    return usdAmount * toCurrency.exchangeRateToUSD;
  }
  
  // Format converted amount
  static String formatConvertedAmount(double amount, Currency fromCurrency, Currency toCurrency) {
    final convertedAmount = convertCurrency(amount, fromCurrency, toCurrency);
    return formatCurrency(convertedAmount, toCurrency);
  }
}

