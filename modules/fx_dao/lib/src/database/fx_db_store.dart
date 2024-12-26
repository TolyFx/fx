import 'dart:async';
import '../../fx_dao.dart';


abstract class FxDb extends DbStore with DbOpenMixin {
  T call<T extends Dao>() {
    DbTable? table = _tableMap[T];
    if(table is T) return table as T;
    throw 'FxDb cast Exception::[${table.runtimeType} is not type: $T]';
  }

  final Map<Type, DbTable> _tableMap = {};
  final DbMigration _migration = DbMigration();

  FxDb() {
    for (DbTable table in tables) {
      _tableMap[table.runtimeType] = table;
    }

    for ((int, MigrationOperation) merge in migrations) {
      _migration.addMigration(merge.$1, merge.$2);
    }
  }

  Iterable<DbTable> get tables;

  Iterable<(int, MigrationOperation)> get migrations;

  @override
  Future<void> onCreate(Database db, int version) async {
    await Future.wait(_tableMap.values.map((e) => e.create(db, version)));
    await _migration.migration(db, 1, version);
  }

  @override
  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _migration.migration(db, oldVersion, newVersion);
    return super.onUpgrade(db, oldVersion, newVersion);
  }

  @override
  void afterOpen(String dbpath) {
    super.afterOpen(dbpath);
    _migration.clear();
    for (DbTable e in _tableMap.values) {
      e.attach(database);
    }
  }

  @override
  Future<void> close() async {
    _tableMap.clear();
    super.close();
  }
}
