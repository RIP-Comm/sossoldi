abstract class BaseEntityFields {
  static String id = 'id';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';

  static String get getId {
    return id;
  }

  static String get getCreatedAt {
    return createdAt;
  }

  static String get getUpdatedAt {
    return updatedAt;
  }
}

abstract class BaseEntity {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseEntity({this.id, this.createdAt, this.updatedAt});
}
