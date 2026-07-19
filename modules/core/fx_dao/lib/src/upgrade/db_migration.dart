import 'package:sqflite/sqflite.dart';

typedef MigrationOperation = Future<void> Function(Database database);

class DbMigration {
  final Map<int, MigrationOperation> _migrationMap = {};

  void addMigration(int version, MigrationOperation operation) {
    _migrationMap[version] = operation;
  }

  /// 执行 (oldVersion, newVersion] 范围内的迁移，按版本号升序执行。
  Future<void> migration(Database database, int oldVersion, int newVersion) async {
    final List<int> versions = _migrationMap.keys
        .where((int v) => v > oldVersion && v <= newVersion)
        .toList()
      ..sort();

    for (final int version in versions) {
      await _migrationMap[version]!(database);
    }
  }

  void clear() {
    _migrationMap.clear();
  }
}
