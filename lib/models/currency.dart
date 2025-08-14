

class Currency {
  final String code;
  final String name;
  final String symbol;
  final double exchangeRateToUSD; // Base exchange rate to USD

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.exchangeRateToUSD = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchangeRateToUSD': exchangeRateToUSD,
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] ?? 'USD',
      name: json['name'] ?? 'US Dollar',
      symbol: json['symbol'] ?? '\$',
      exchangeRateToUSD: json['exchangeRateToUSD']?.toDouble() ?? 1.0,
    );
  }

  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    double? exchangeRateToUSD,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      exchangeRateToUSD: exchangeRateToUSD ?? this.exchangeRateToUSD,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$name ($code)';
}

// Predefined popular currencies
class Currencies {
  static const Currency ugx = Currency(
    code: 'UGX',
    name: 'Ugandan Shilling',
    symbol: 'UGX',
    exchangeRateToUSD: 3700.0, // Approximate rate
  );

  static const Currency usd = Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    exchangeRateToUSD: 1.0,
  );

  static const Currency eur = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    exchangeRateToUSD: 0.85, // Approximate rate
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    exchangeRateToUSD: 0.75, // Approximate rate
  );

  static const Currency kes = Currency(
    code: 'KES',
    name: 'Kenyan Shilling',
    symbol: 'KSh',
    exchangeRateToUSD: 150.0, // Approximate rate
  );

  static const Currency tzs = Currency(
    code: 'TZS',
    name: 'Tanzanian Shilling',
    symbol: 'TSh',
    exchangeRateToUSD: 2500.0, // Approximate rate
  );

  static const Currency rwf = Currency(
    code: 'RWF',
    name: 'Rwandan Franc',
    symbol: 'RWF',
    exchangeRateToUSD: 1200.0, // Approximate rate
  );

  static const Currency ngn = Currency(
    code: 'NGN',
    name: 'Nigerian Naira',
    symbol: '₦',
    exchangeRateToUSD: 800.0, // Approximate rate
  );

  static const Currency zar = Currency(
    code: 'ZAR',
    name: 'South African Rand',
    symbol: 'R',
    exchangeRateToUSD: 18.0, // Approximate rate
  );

  static const Currency ghs = Currency(
    code: 'GHS',
    name: 'Ghanaian Cedi',
    symbol: 'GH₵',
    exchangeRateToUSD: 12.0, // Approximate rate
  );

  static const Currency cad = Currency(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    exchangeRateToUSD: 1.35, // Approximate rate
  );

  static const Currency aud = Currency(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    exchangeRateToUSD: 1.50, // Approximate rate
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    exchangeRateToUSD: 150.0, // Approximate rate
  );

  static const Currency cny = Currency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    exchangeRateToUSD: 7.2, // Approximate rate
  );

  static const Currency inr = Currency(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    exchangeRateToUSD: 83.0, // Approximate rate
  );

  // List of all supported currencies
  static const List<Currency> all = [
    ugx,
    usd,
    eur,
    gbp,
    kes,
    tzs,
    rwf,
    ngn,
    zar,
    ghs,
    cad,
    aud,
    jpy,
    cny,
    inr,
  ];

  // Get currency by code
  static Currency? getByCode(String code) {
    try {
      return all.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  // Get default currency (UGX)
  static Currency getDefault() => ugx;
}
