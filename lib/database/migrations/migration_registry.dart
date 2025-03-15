/// Manages database migrations for the application.
///
/// This registry maintains the list of all database migrations in the order they should be executed.
/// When adding new migrations to this list, please follow these guidelines:
///
/// 1. Add migrations in ascending version order
/// 2. When two migrations share the same version number, their order in this list
///    determines execution order (first in the list = executed first)
/// 3. Use descriptive file names that include the version number (e.g., 0002_add_transaction_indexes.dart)
///
/// The MigrationManager will execute migrations in the exact order defined here.
library;


import '0001_initial_schema.dart';
import '../migration_base.dart';


/// Returns all available migrations in execution order.
///
/// IMPORTANT: The order of migrations in this list is critical!
/// Migrations are executed in the order they appear here, not necessarily by their version number.
/// When multiple migrations share the same version number, their position in this list
/// determines which runs first.
List<Migration> getMigrations() {
  return [
    InitialSchema()
    // Add future migrations here
  ];
}

/// Returns the highest migration version number across all migrations.
/// Used to determine the current database schema version.
///
/// NOTE: This should return the maximum version number found in any migration,
/// not just the version of the last migration in the list. If migrations aren't
/// added in strict version order, make sure this function still returns the highest version.
int getLatestVersion() {
  final migrations = getMigrations();
  if (migrations.isEmpty) return 1;

  return migrations.fold<int>(1, (max, migration) =>
  migration.version > max ? migration.version : max);
}