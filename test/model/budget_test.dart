import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/budget.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Budget', () {
    Budget b = Budget(
        id: 2,
        idCategory: 2,
        name: 'Test',
        amountLimit: 100,
        active: true,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Budget bCopy = b.copy(id: 10);

    assert(bCopy.id == 10);
    assert(bCopy.idCategory == b.idCategory);
    assert(bCopy.name == b.name);
    assert(bCopy.amountLimit == bCopy.amountLimit);
    assert(bCopy.active == bCopy.active);
    assert(bCopy.createdAt == b.createdAt);
    assert(bCopy.updatedAt == b.updatedAt);
  });

  test("Test fromJson Budget", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      BudgetFields.idCategory: 3,
      BudgetFields.name: 'Test',
      BudgetFields.amountLimit: 100,
      BudgetFields.active: false,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Budget b = Budget.fromJson(json);

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.idCategory == json[BudgetFields.idCategory]);
    assert(b.name == json[BudgetFields.name]);
    assert(b.amountLimit == json[BudgetFields.amountLimit]);
    assert(b.active == json[BudgetFields.active]);
    assert(b.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(b.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Budget", () {
    Budget b = const Budget(
        id: 2, idCategory: 2, name: 'Test', amountLimit: 100, active: true);

    Map<String, Object?> json = b.toJson(update: true);

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.idCategory == json[BudgetFields.idCategory]);
    assert(b.name == json[BudgetFields.name]);
    assert(b.amountLimit == json[BudgetFields.amountLimit]);
    assert(b.active == json[BudgetFields.active]);
  });
}
