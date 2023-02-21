import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/budget.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Budget', () {
    Budget b = Budget(
        id: 2,
        idCategory: 2,
        amountLimit: 100,
        active: 1,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Budget bCopy = b.copy(id: 10);

    assert(bCopy.id == 10);
    assert(bCopy.idCategory == b.idCategory);
    assert(bCopy.amountLimit == bCopy.amountLimit);
    assert(bCopy.active == bCopy.active);
    assert(bCopy.createdAt == b.createdAt);
    assert(bCopy.updatedAt == b.updatedAt);
  });

  test("Test fromJson Budget", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      BudgetFields.idCategory: 3,
      BudgetFields.amountLimit: 100,
      BudgetFields.active: 0,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Budget b = Budget.fromJson(json);

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.idCategory == json[BudgetFields.idCategory]);
    assert(b.amountLimit == json[BudgetFields.amountLimit]);
    assert(b.active == json[BudgetFields.active]);
    assert(b.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(b.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Budget", () {
    Budget b = Budget(
        id: 2,
        idCategory: 2,
        amountLimit: 100,
        active: 1,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = b.toJson();

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.idCategory == json[BudgetFields.idCategory]);
    assert(b.amountLimit == json[BudgetFields.amountLimit]);
    assert(b.active == json[BudgetFields.active]);
    assert(b.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(b.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
