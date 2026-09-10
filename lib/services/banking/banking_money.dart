// dart format width=400

class BankingMoney {
  final String decimalAmount;
  final String currency;

  BankingMoney({required this.decimalAmount, required this.currency}) {
    if (!RegExp(r'^-?[0-9]+(?:\.[0-9]+)?$').hasMatch(decimalAmount) || !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw const FormatException('Invalid banking amount');
    }
  }
}
