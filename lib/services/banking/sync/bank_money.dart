/// Exact bank money, persisted as decimal minor units rather than SQLite REAL.
class BankMoney {
  final String currency;
  final BigInt minorUnits;
  final int scale;

  BankMoney._(this.currency, this.minorUnits, this.scale);

  // Unsupported codes fail closed until their scale is explicitly supported.
  static const scales = <String, int>{
    'EUR': 2,
    'USD': 2,
    'GBP': 2,
    'CHF': 2,
    'CAD': 2,
    'AUD': 2,
    'NZD': 2,
    'SEK': 2,
    'NOK': 2,
    'DKK': 2,
    'PLN': 2,
    'CZK': 2,
    'HUF': 2,
    'RON': 2,
    'BGN': 2,
    'ISK': 0,
    'JPY': 0,
    'KRW': 0,
    'CLP': 0,
    'BHD': 3,
    'KWD': 3,
    'OMR': 3,
    'JOD': 3,
    'TND': 3,
  };

  factory BankMoney.parse(String amount, String currency) {
    final scale = scales[currency];
    if (scale == null || amount.length > 40) {
      throw const FormatException('Unsupported currency or amount range');
    }
    final match = RegExp(r'^(-?)([0-9]+)(?:\.([0-9]+))?$').firstMatch(amount);
    if (match == null) throw const FormatException('Invalid decimal amount');
    final fraction = match[3] ?? '';
    if (fraction.length > scale &&
        fraction.substring(scale).contains(RegExp('[1-9]'))) {
      throw const FormatException('Amount exceeds currency precision');
    }
    final padded = fraction.padRight(scale, '0').substring(0, scale);
    final magnitude = BigInt.parse('${match[2]}$padded');
    return BankMoney._(
      currency,
      match[1] == '-' ? -magnitude : magnitude,
      scale,
    );
  }

  factory BankMoney.fromMinor(String units, String currency) {
    final scale = scales[currency];
    if (scale == null) throw const FormatException('Unsupported currency');
    return BankMoney._(currency, BigInt.parse(units), scale);
  }

  BankMoney get negated => BankMoney._(currency, -minorUnits, scale);

  BankMoney operator +(BankMoney other) {
    if (currency != other.currency) {
      throw const FormatException('Currency mismatch');
    }
    return BankMoney._(currency, minorUnits + other.minorUnits, scale);
  }

  BankMoney operator -(BankMoney other) => this + other.negated;

  String get decimal {
    final digits = minorUnits.abs().toString().padLeft(scale + 1, '0');
    final sign = minorUnits.isNegative ? '-' : '';
    if (scale == 0) return '$sign$digits';
    final split = digits.length - scale;
    return '$sign${digits.substring(0, split)}.${digits.substring(split)}';
  }

  /// The legacy UI receives a bounded projection; exact units remain authoritative.
  num get projection {
    if (minorUnits.abs() > BigInt.from(9999999999999)) {
      throw const FormatException('Amount exceeds legacy display range');
    }
    final value = double.parse(decimal);
    if (BankMoney.parse(value.toStringAsFixed(scale), currency).minorUnits !=
        minorUnits) {
      throw const FormatException('Amount cannot be projected safely');
    }
    return value;
  }
}
