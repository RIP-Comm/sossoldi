import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/category_recurring_transaction.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Recurring Category Transaction', () {
    CategoryRecurringTransaction c = CategoryRecurringTransaction(
        id: 2,
        name: "name",
        symbol: "symbol",
        note: "note",
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    CategoryRecurringTransaction cCopy = c.copy(id: 10);

    assert(cCopy.id == 10);
    assert(cCopy.name == c.name);
    assert(cCopy.symbol == c.symbol);
    assert(cCopy.note == c.note);
    assert(cCopy.createdAt == c.createdAt);
    assert(cCopy.updatedAt == c.updatedAt);
  });

  test("Test fromJson Recurring Category Transaction", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      CategoryRecurringTransactionFields.name: "name",
      CategoryRecurringTransactionFields.symbol: "symbol",
      CategoryRecurringTransactionFields.note: "note",
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    CategoryRecurringTransaction c =
        CategoryRecurringTransaction.fromJson(json);

    assert(c.id == json[BaseEntityFields.id]);
    assert(c.name == json[CategoryRecurringTransactionFields.name]);
    assert(c.symbol == json[CategoryRecurringTransactionFields.symbol]);
    assert(c.note == json[CategoryRecurringTransactionFields.note]);
    assert(c.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(c.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Recurring Category Transaction", () {
    CategoryRecurringTransaction c = CategoryRecurringTransaction(
        id: 2,
        name: "name",
        symbol: "symbol",
        note: "note",
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = c.toJson();

    assert(c.id == json[BaseEntityFields.id]);
    assert(c.name == json[CategoryRecurringTransactionFields.name]);
    assert(c.symbol == json[CategoryRecurringTransactionFields.symbol]);
    assert(c.note == json[CategoryRecurringTransactionFields.note]);
    assert(c.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(c.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
