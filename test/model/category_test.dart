import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/category.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Category', () {
    Category c = Category(
        id: 2,
        name: "name",
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Category cCopy = c.copy(id: 10);

    assert(cCopy.id == 10);
    assert(cCopy.name == c.name);
    assert(cCopy.createdAt == c.createdAt);
    assert(cCopy.updatedAt == c.updatedAt);
  });

  test("Test fromJson Category", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      CategoryFields.name: "Home",
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Category c = Category.fromJson(json);

    assert(c.id == json[BaseEntityFields.id]);
    assert(c.name == json[CategoryFields.name]);
    assert(c.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(c.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Category", () {
    Category c = Category(
        id: 2,
        name: "Home",
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    Map<String, Object?> json = c.toJson();

    assert(c.id == json[BaseEntityFields.id]);
    assert(c.name == json[CategoryFields.name]);
    assert(c.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(c.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });
}
