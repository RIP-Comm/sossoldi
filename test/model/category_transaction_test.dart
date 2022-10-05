import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Category', () {
    CategoryTransaction c = CategoryTransaction(
        id: 2,
        name: "name",
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    CategoryTransaction cCopy = c.copy(id: 10);

    assert(cCopy.id == 10);
    assert(cCopy.name == c.name);
    assert(cCopy.createdAt == c.createdAt);
    assert(cCopy.updatedAt == c.updatedAt);
  });

  test("Test fromJson Category", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      CategoryTransactionFields.name: "Home",
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    CategoryTransaction c = CategoryTransaction.fromJson(json);

    assert(c.id == json[BaseEntityFields.id]);
    assert(c.name == json[CategoryTransactionFields.name]);
    assert(c.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(c.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Category", () {
    CategoryTransaction c = CategoryTransaction(
        id: 2,
        name: "Home",
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = c.toJson();

    assert(c.id == json[BaseEntityFields.id]);
    assert(c.name == json[CategoryTransactionFields.name]);
    assert(c.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(c.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
