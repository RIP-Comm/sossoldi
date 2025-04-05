import 'package:sossoldi/model/transaction.dart';

String createInsertSqlTransaction(
    {DateTime? date,
    double amount = 100,
    String type = 'OUT',
    String note = 'Test Transaction',
    int idCategory = 10, // Out
    int idBankAccount = 70, // Revolut
    int? idBankTransfert,
    bool recurring = false,
    int? idRecurringTransaction,
    Recurrence? recurrencyType,
    int? recurrencyPayDay,
    DateTime? recurrencyFrom,
    DateTime? recurrencyTo,
    DateTime? createdAt,
    DateTime? updatedAt}) {
  date = date ?? DateTime.now();
  createdAt = date;
  updatedAt = date;
  int recurringInt = recurring ? 1 : 0;
  return '''('$date', $amount, '$type', '$note', $idCategory, $idBankAccount, $idBankTransfert, $recurringInt, $idRecurringTransaction, '$createdAt', '$updatedAt')''';
}
