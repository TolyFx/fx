import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dao/src/upgrade/db_migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath, version: 1);
  });

  tearDown(() async {
    await db.close();
  });

  group('DbMigration', () {
    test('从 v2 升级到 v4，执行 v3 和 v4 的迁移', () async {
      final List<int> executed = [];
      final DbMigration migration = DbMigration();
      migration.addMigration(2, (_) async => executed.add(2));
      migration.addMigration(3, (_) async => executed.add(3));
      migration.addMigration(4, (_) async => executed.add(4));

      // 从 v2 升到 v4，应执行 (2, 4] 即 v3, v4
      await migration.migration(db, 2, 4);
      expect(executed, [3, 4]);
    });

    test('从 v1 升级到 v3，执行 v2 和 v3', () async {
      final List<int> executed = [];
      final DbMigration migration = DbMigration();
      migration.addMigration(2, (_) async => executed.add(2));
      migration.addMigration(3, (_) async => executed.add(3));

      await migration.migration(db, 1, 3);
      expect(executed, [2, 3]);
    });

    test('乱序注册仍按版本号顺序执行', () async {
      final List<int> executed = [];
      final DbMigration migration = DbMigration();
      migration.addMigration(4, (_) async => executed.add(4));
      migration.addMigration(2, (_) async => executed.add(2));
      migration.addMigration(3, (_) async => executed.add(3));

      await migration.migration(db, 1, 4);
      expect(executed, [2, 3, 4]);
    });

    test('相同版本不执行', () async {
      final List<int> executed = [];
      final DbMigration migration = DbMigration();
      migration.addMigration(2, (_) async => executed.add(2));

      await migration.migration(db, 2, 2);
      expect(executed, isEmpty);
    });

    test('clear 后无迁移', () async {
      final List<int> executed = [];
      final DbMigration migration = DbMigration();
      migration.addMigration(2, (_) async => executed.add(2));
      migration.clear();

      await migration.migration(db, 1, 5);
      expect(executed, isEmpty);
    });
  });
}
