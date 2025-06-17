import 'package:sqflite/sqflite.dart';

/// Represents a database migration that can be applied to evolve the schema.
///
/// Each migration has a database [version] number and a [description] that
/// explains what the migration does.
/// Migrations are collected in the migration registry and executed in order based
/// on their version numbers when the database needs to be created or upgraded.
///
/// To create a new migration:
/// 1. Extend this class with a concrete implementation
/// 2. Implement the [up] method with the schema changes
/// 3. (optional) Implement the [down] method to revert those changes
/// 4. Add your migration to the registry in `migration_registry.dart`
///
/// Example:
/// ```dart
/// class AddUserAvatarMigration extends Migration {
///   AddUserAvatarMigration()
///     : super(
///         version: 3,
///         description: 'Add avatar column to user table'
///       );
///
///   @override
///   Future<void> up(Database db) async {
///     await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
///   }
///
///   @override
///   Future<void> down(Database db) async {
///     // reserved for future use
///   }
/// }
/// ```
abstract class Migration {
  /// The database version number of this migration.
  final int version;

  /// A description of what this migration does.
  final String description;

  Migration({required this.version, required this.description});

  /// Applies this migration to upgrade the database schema.
  Future<void> up(Database db);
}
