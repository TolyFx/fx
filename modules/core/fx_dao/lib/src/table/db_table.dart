

import 'package:sqflite/sqflite.dart';

import '../database/has_database.dart';

mixin DbTable on HasDatabase {
  String get name;

  String get createSql;

  Future<void> create(Database database, int version) {
    return database.execute(createSql);
  }

  void attach(Database database) {
    this.database = database;
  }
}