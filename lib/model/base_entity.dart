abstract class BaseEntityFields {
  static String id = 'id';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';
  static String deletedAt = 'deletedAt';

  static String get getId {
    return id;
  }

  static String get getCreatedAt {
    return createdAt;
  }

  static String get getUpdatedAt {
    return updatedAt;
  }

  static String get getDeletedAt {
    return deletedAt;
  }
}

abstract class BaseEntity {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const BaseEntity({this.id, this.createdAt, this.updatedAt, this.deletedAt});
}
