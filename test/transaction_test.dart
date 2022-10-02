// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
        idBankAccount: 0,
        idBudget: "Casa",
        idCategory: 0,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Transaction tCopy = t.copy(id: 10);

    assert(tCopy.id == 10);
    assert(tCopy.date == t.date);
    assert(tCopy.amount == t.amount);
    assert(tCopy.date == t.date);
    assert(tCopy.type == t.type);
    assert(tCopy.idBankAccount == t.idBankAccount);
    assert(tCopy.idBudget == t.idBudget);
    assert(tCopy.idBudget == t.idBudget);
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
      TransactionFields.idBankAccount: 0,
      TransactionFields.idBudget: "Casa",
      TransactionFields.idCategory: 0,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Transaction t = Transaction.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type.index == json[TransactionFields.type]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.idBankAccount == json[TransactionFields.idBankAccount]);
    assert(t.idBudget == json[TransactionFields.idBudget]);
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
        idBankAccount: 0,
        idBudget: "Casa",
        idCategory: 0);

    Map<String, Object?> json = t.toJson();
    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type.index == json[TransactionFields.type]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.idBankAccount == json[TransactionFields.idBankAccount]);
    assert(t.idBudget == json[TransactionFields.idBudget]);
    assert(t.idCategory == json[TransactionFields.idCategory]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
