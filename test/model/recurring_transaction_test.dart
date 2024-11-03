import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/recurring_transaction.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Recurring Transaction Amount', () {
    DateTime toDateValue = DateTime.utc(2023);
    RecurringTransaction t = RecurringTransaction(
        id: 2,
        fromDate: DateTime.utc(2022),
        toDate: toDateValue,
        amount: 14,
        note: 'Test Transaction',
        recurrency: 'MONTHLY',
        idBankAccount: 34,
        idCategory: 24,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022)
    );

    RecurringTransaction tCopy = t.copy(id: 10, toDate: toDateValue);

    assert(tCopy.id == 10);
    assert(tCopy.fromDate == t.fromDate);
    assert(tCopy.toDate == toDateValue);
    assert(tCopy.amount == t.amount);
    assert(tCopy.note == t.note);
    assert(tCopy.recurrency == t.recurrency);
    assert(tCopy.idBankAccount == t.idBankAccount);
    assert(tCopy.idCategory == t.idCategory);
    assert(tCopy.createdAt == t.createdAt);
    assert(tCopy.updatedAt == t.updatedAt);
  });

  test("Test fromJson Recurring Transaction Amount", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      RecurringTransactionFields.fromDate: DateTime.utc(2022).toIso8601String(),
      RecurringTransactionFields.toDate: DateTime.utc(2023).toIso8601String(),
      RecurringTransactionFields.amount: 50,
      RecurringTransactionFields.note: "Test Transaction",
      RecurringTransactionFields.recurrency: "WEEKLY",
      RecurringTransactionFields.idBankAccount: 44,
      RecurringTransactionFields.idCategory: 4,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    RecurringTransaction t = RecurringTransaction.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.fromDate.toUtc().toIso8601String() == json[RecurringTransactionFields.fromDate]);
    assert(t.toDate?.toUtc().toIso8601String() == json[RecurringTransactionFields.toDate]);
    assert(t.amount == json[RecurringTransactionFields.amount]);
    assert(t.note == json[RecurringTransactionFields.note]);
    assert(t.recurrency == json[RecurringTransactionFields.recurrency]);
    assert(t.idBankAccount == json[RecurringTransactionFields.idBankAccount]);
    assert(t.idCategory == json[RecurringTransactionFields.idCategory]);
    assert(t.createdAt?.toUtc().toIso8601String() == json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() == json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Recurring Transaction Amount", () {
    RecurringTransaction t = RecurringTransaction(
        id: 2,
        fromDate: DateTime.utc(2022),
        toDate: DateTime.utc(2023),
        amount: 0,
        note: "Test transaction",
        recurrency: "MONTHLY",
        idBankAccount: 4,
        idCategory: 45,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = t.toJson();

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.fromDate.toUtc().toIso8601String() == json[RecurringTransactionFields.fromDate]);
    assert(t.toDate?.toUtc().toIso8601String() == json[RecurringTransactionFields.toDate]);
    assert(t.amount == json[RecurringTransactionFields.amount]);
    assert(t.note == json[RecurringTransactionFields.note]);
    assert(t.recurrency == json[RecurringTransactionFields.recurrency]);
    assert(t.idBankAccount == json[RecurringTransactionFields.idBankAccount]);
    assert(t.idCategory == json[RecurringTransactionFields.idCategory]);
    assert(t.createdAt?.toUtc().toIso8601String() == json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() == json[BaseEntityFields.updatedAt]);
  });
}
