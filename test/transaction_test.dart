// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/main.dart';

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
        idCategory: 0);

    Transaction tCopy = t.copy(id: 10);
    assert(tCopy.id == 10);
    assert(tCopy.date == t.date);
  });

  test("Test Json Transaction", () {
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
  });
}
