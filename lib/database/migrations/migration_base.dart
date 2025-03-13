import 'package:sqflite/sqflite.dart';

abstract class Migration {
  final int version;
  final String description;

  Migration(this.version, this.description);

  Future<void> up(Database db);
  Future<void> down(Database db);
}