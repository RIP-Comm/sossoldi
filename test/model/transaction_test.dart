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
        nameBankAccount: 0,
        nameBudget: "Home",
        nameCategory: 0,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Transaction tCopy = t.copy(id: 10);

    assert(tCopy.id == 10);
    assert(tCopy.date == t.date);
    assert(tCopy.amount == t.amount);
    assert(tCopy.date == t.date);
    assert(tCopy.type == t.type);
    assert(tCopy.nameBankAccount == t.nameBankAccount);
    assert(tCopy.nameBudget == t.nameBudget);
    assert(tCopy.nameBudget == t.nameBudget);
    assert(tCopy.createdAt == t.createdAt);
    assert(tCopy.updatedAt == t.updatedAt);
  });

  test("Test fromJson Transaction", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      TransactionFields.date: DateTime.utc(2022).toIso8601String(),
      TransactionFields.amount: 100,
      TransactionFields.type: Type.income.index,
      TransactionFields.note: "Note",
      TransactionFields.nameBankAccount: 0,
      TransactionFields.nameBudget: "Home",
      TransactionFields.nameCategory: 0,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Transaction t = Transaction.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type.index == json[TransactionFields.type]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.nameBankAccount == json[TransactionFields.nameBankAccount]);
    assert(t.nameBudget == json[TransactionFields.nameBudget]);
    assert(t.nameCategory == json[TransactionFields.nameCategory]);
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
        nameBankAccount: 0,
        nameBudget: "Home",
        nameCategory: 0,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = t.toJson();

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type.index == json[TransactionFields.type]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.nameBankAccount == json[TransactionFields.nameBankAccount]);
    assert(t.nameBudget == json[TransactionFields.nameBudget]);
    assert(t.nameCategory == json[TransactionFields.nameCategory]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
