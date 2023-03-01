import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/recurring_transaction_amount.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Recurring Transaction Amount', () {
    RecurringTransactionAmount t = RecurringTransactionAmount(
        id: 2,
        from: DateTime.utc(2022),
        to: DateTime.utc(2023),
        amount: 0,
        idTransaction: 0,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    RecurringTransactionAmount tCopy = t.copy(id: 10);

    assert(tCopy.id == 10);
    assert(tCopy.from == t.from);
    assert(tCopy.to == t.to);
    assert(tCopy.amount == t.amount);
    assert(tCopy.idTransaction == t.idTransaction);
    assert(tCopy.createdAt == t.createdAt);
    assert(tCopy.updatedAt == t.updatedAt);
  });

  test("Test fromJson Recurring Transaction Amount", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      RecurringTransactionAmountFields.from:
          DateTime.utc(2022).toIso8601String(),
      RecurringTransactionAmountFields.to: DateTime.utc(2023).toIso8601String(),
      RecurringTransactionAmountFields.amount: 0,
      RecurringTransactionAmountFields.idTransaction: 0,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    RecurringTransactionAmount t = RecurringTransactionAmount.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.from.toUtc().toIso8601String() ==
        json[RecurringTransactionAmountFields.from]);
    assert(t.to.toUtc().toIso8601String() ==
        json[RecurringTransactionAmountFields.to]);
    assert(t.amount == json[RecurringTransactionAmountFields.amount]);
    assert(t.idTransaction ==
        json[RecurringTransactionAmountFields.idTransaction]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Recurring Transaction Amount", () {
    RecurringTransactionAmount t = RecurringTransactionAmount(
        id: 2,
        from: DateTime.utc(2022),
        to: DateTime.utc(2023),
        amount: 0,
        idTransaction: 0,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = t.toJson();

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.from.toUtc().toIso8601String() ==
        json[RecurringTransactionAmountFields.from]);
    assert(t.to.toUtc().toIso8601String() ==
        json[RecurringTransactionAmountFields.to]);
    assert(t.amount == json[RecurringTransactionAmountFields.amount]);
    assert(t.idTransaction ==
        json[RecurringTransactionAmountFields.idTransaction]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
