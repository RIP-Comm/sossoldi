import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/recurring_transaction.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Recurring Transaction', () {
    RecurringTransaction t = RecurringTransaction(
        id: 2,
        from: DateTime.utc(2022),
        to: DateTime.utc(2023),
        payDay: 1,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    RecurringTransaction tCopy = t.copy(id: 10);

    assert(tCopy.id == 10);
    assert(tCopy.from == t.from);
    assert(tCopy.to == t.to);
    assert(tCopy.payDay == t.payDay);
    assert(tCopy.createdAt == t.createdAt);
    assert(tCopy.updatedAt == t.updatedAt);
  });

  test("Test fromJson Recurring Transaction", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      RecurringTransactionFields.from: DateTime.utc(2022).toIso8601String(),
      RecurringTransactionFields.to: DateTime.utc(2023).toIso8601String(),
      RecurringTransactionFields.payDay: 1,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    RecurringTransaction t = RecurringTransaction.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.from.toUtc().toIso8601String() ==
        json[RecurringTransactionFields.from]);
    assert(
        t.to.toUtc().toIso8601String() == json[RecurringTransactionFields.to]);
    assert(t.payDay == json[RecurringTransactionFields.payDay]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Recurring Transaction", () {
    RecurringTransaction t = RecurringTransaction(
        id: 2,
        from: DateTime.utc(2022),
        to: DateTime.utc(2023),
        payDay: 1,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = t.toJson();

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.from.toUtc().toIso8601String() ==
        json[RecurringTransactionFields.from]);
    assert(
        t.to.toUtc().toIso8601String() == json[RecurringTransactionFields.to]);
    assert(t.payDay == json[RecurringTransactionFields.payDay]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
