import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Transaction', () {
    Transaction t = Transaction(
        id: 2,
        date: DateTime.utc(2022),
        amount: 100,
        type: Type.income,
        note: "Note",
        idBankAccount: 0,
        idBankAccountTransfer: null,
        recurring: false,
        recurrencyType: null,
        recurrencyPayDay: null,
        recurrencyFrom: null,
        recurrencyTo: null,
        idCategory: 1,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Transaction tCopy = t.copy(id: 10);

    assert(tCopy.id == 10);
    assert(tCopy.date == t.date);
    assert(tCopy.amount == t.amount);
    assert(tCopy.date == t.date);
    assert(tCopy.note == t.note);
    assert(tCopy.type == t.type);
    assert(tCopy.idBankAccount == t.idBankAccount);
    assert(tCopy.idCategory == t.idCategory);
    assert(tCopy.idBankAccountTransfer == t.idBankAccountTransfer);
    assert(tCopy.recurring == t.recurring);
    assert(tCopy.recurrencyType == t.recurrencyType);
    assert(tCopy.recurrencyPayDay == t.recurrencyPayDay);
    assert(tCopy.recurrencyFrom == t.recurrencyFrom);
    assert(tCopy.recurrencyTo == t.recurrencyTo);
    assert(tCopy.createdAt == t.createdAt);
    assert(tCopy.updatedAt == t.updatedAt);
  });

  test("Test fromJson Transaction", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      TransactionFields.date: DateTime.utc(2022).toIso8601String(),
      TransactionFields.amount: 100,
      TransactionFields.type: "IN",
      TransactionFields.note: "Note",
      TransactionFields.idBankAccount: 0,
      TransactionFields.idCategory: 0,
      TransactionFields.idBankAccountTransfer: null,
      TransactionFields.recurring: false,
      TransactionFields.recurrencyType: null,
      TransactionFields.recurrencyPayDay: null,
      TransactionFields.recurrencyFrom: null,
      TransactionFields.recurrencyTo: null,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Transaction t = Transaction.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type == typeMap[json[TransactionFields.type]]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.idBankAccount == json[TransactionFields.idBankAccount]);
    assert(t.idBankAccountTransfer == json[TransactionFields.idBankAccountTransfer]);
    assert(t.recurring == json[TransactionFields.recurring]);
    assert(t.recurrencyType == json[TransactionFields.recurrencyType]);
    assert(t.recurrencyPayDay == json[TransactionFields.recurrencyPayDay]);
    assert(t.recurrencyFrom == json[TransactionFields.recurrencyFrom]);
    assert(t.recurrencyTo == json[TransactionFields.recurrencyTo]);
    assert(t.idCategory == json[TransactionFields.idCategory]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Transaction", () {
    Transaction t = Transaction(
        id: 2,
        date: DateTime.utc(2022),
        amount: 100,
        type: Type.income,
        note: "Note",
        idCategory: 0,
        idBankAccount: 0,
        idBankAccountTransfer: null,
        recurring: false,
        recurrencyType: null,
        recurrencyPayDay: null,
        recurrencyFrom: null,
        recurrencyTo: null);

    Map<String, Object?> json = t.toJson();

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type == typeMap[json[TransactionFields.type]]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.idCategory == json[TransactionFields.idCategory]);
    assert(t.idBankAccount == json[TransactionFields.idBankAccount]);
    assert(t.idBankAccountTransfer == json[TransactionFields.idBankAccountTransfer]);
    assert((t.recurring ? 1 : 0) == json[TransactionFields.recurring]);
    assert(t.recurrencyType == json[TransactionFields.recurrencyType]);
    assert(t.recurrencyPayDay == json[TransactionFields.recurrencyPayDay]);
    assert(t.recurrencyFrom == json[TransactionFields.recurrencyFrom]);
    assert(t.recurrencyTo == json[TransactionFields.recurrencyTo]);
  });
}
