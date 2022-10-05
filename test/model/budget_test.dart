import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/budget.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Budget', () {
    Budget b = Budget(
        id: 2,
        name: "name",
        amountLimit: 100,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Budget bCopy = b.copy(id: 10);

    assert(bCopy.id == 10);
    assert(bCopy.name == b.name);
    assert(bCopy.amountLimit == bCopy.amountLimit);
    assert(bCopy.createdAt == b.createdAt);
    assert(bCopy.updatedAt == b.updatedAt);
  });

  test("Test fromJson Budget", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      BudgetFields.name: "name",
      BudgetFields.amountLimit: 100,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Budget b = Budget.fromJson(json);

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.name == json[BudgetFields.name]);
    assert(b.amountLimit == json[BudgetFields.amountLimit]);
    assert(b.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(b.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Budget", () {
    Budget b = Budget(
        id: 2,
        name: "name",
        amountLimit: 100,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = b.toJson();

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.name == json[BudgetFields.name]);
    assert(b.amountLimit == json[BudgetFields.amountLimit]);
    assert(b.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(b.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
