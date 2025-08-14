import '../models/currency.dart';

class CurrencyService {
  // Get all available currencies
  static List<Currency> getAllCurrencies() {
    return Currencies.all;
  }

  // Get currency by code
  static Currency? getCurrencyByCode(String code) {
    return Currencies.getByCode(code);
  }

  // Get default currency
  static Currency getDefaultCurrency() {
    return Currencies.getDefault();
  }

  // Get popular African currencies
  static List<Currency> getAfricanCurrencies() {
    return [
      Currencies.ugx,
      Currencies.kes,
      Currencies.tzs,
      Currencies.rwf,
      Currencies.ngn,
      Currencies.zar,
      Currencies.ghs,
    ];
  }

  // Get major international currencies
  static List<Currency> getMajorCurrencies() {
    return [
      Currencies.usd,
      Currencies.eur,
      Currencies.gbp,
      Currencies.jpy,
      Currencies.cad,
      Currencies.aud,
      Currencies.cny,
      Currencies.inr,
    ];
  }

  // Search currencies by name or code
  static List<Currency> searchCurrencies(String query) {
    if (query.isEmpty) return getAllCurrencies();
    
    final lowercaseQuery = query.toLowerCase();
    return getAllCurrencies().where((currency) {
      return currency.name.toLowerCase().contains(lowercaseQuery) ||
             currency.code.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get currency display name
  static String getCurrencyDisplayName(Currency currency) {
    return '${currency.name} (${currency.code})';
  }

  // Validate currency
  static bool isValidCurrency(Currency? currency) {
    return currency != null && getAllCurrencies().contains(currency);
  }

  // Get currency by symbol
  static Currency? getCurrencyBySymbol(String symbol) {
    try {
      return getAllCurrencies().firstWhere((currency) => currency.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  // Check if currency is supported
  static bool isCurrencySupported(String code) {
    return getCurrencyByCode(code) != null;
  }

  // Get recommended currencies based on region (future enhancement)
  static List<Currency> getRecommendedCurrencies() {
    // Return all available currencies for maximum choice
    return getAllCurrencies();
  }

  // Get popular/commonly used currencies (original 8)
  static List<Currency> getPopularCurrencies() {
    return [
      Currencies.ugx,
      Currencies.usd,
      Currencies.eur,
      Currencies.kes,
      Currencies.tzs,
      Currencies.ngn,
      Currencies.gbp,
      Currencies.zar,
    ];
  }
}
