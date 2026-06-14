import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dao/src/model/query_args.dart';

void main() {
  group('Query 基础', () {
    test('无条件查询', () {
      final Query query = Query(table: 'users');
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, 'SELECT * FROM users LIMIT 20 OFFSET 0');
      expect(result.args, isEmpty);
    });

    test('指定字段', () {
      final Query query = Query(table: 'users', selectFields: ['id', 'name']);
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, startsWith('SELECT id, name FROM users'));
    });

    test('分页', () {
      final Query query = Query(table: 'users', page: 3, pageSize: 10);
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('LIMIT 10 OFFSET 20'));
    });
  });

  group('Filter 操作符', () {
    test('eq', () {
      final Query query = Query(
        table: 'users',
        filters: [Filter.eq('name', 'Tom')],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('name = ?'));
      expect(result.args, ['Tom']);
    });

    test('ne', () {
      final Query query = Query(
        table: 'users',
        filters: [Filter.ne('status', 0)],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('status != ?'));
      expect(result.args, [0]);
    });

    test('gt / lt / gte / lte', () {
      final Query query = Query(
        table: 'users',
        filters: [
          Filter.gt('age', 18),
          Filter.lt('age', 60),
          Filter.gte('score', 80),
          Filter.lte('score', 100),
        ],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('age > ?'));
      expect(result.sql, contains('age < ?'));
      expect(result.sql, contains('score >= ?'));
      expect(result.sql, contains('score <= ?'));
      expect(result.args, [18, 60, 80, 100]);
    });

    test('like', () {
      final Query query = Query(
        table: 'users',
        filters: [Filter.like('name', '张')],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('name LIKE ?'));
      expect(result.args, ['%张%']);
    });

    test('inList', () {
      final Query query = Query(
        table: 'users',
        filters: [Filter.inList('id', [1, 2, 3])],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('id IN (?, ?, ?)'));
      expect(result.args, [1, 2, 3]);
    });

    test('between', () {
      final Query query = Query(
        table: 'users',
        filters: [Filter.between('age', 18, 60)],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('age BETWEEN ? AND ?'));
      expect(result.args, [18, 60]);
    });

    test('isNull / isNotNull', () {
      final Query query = Query(
        table: 'users',
        filters: [Filter.isNull('email'), Filter.isNotNull('name')],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('email IS NULL'));
      expect(result.sql, contains('name IS NOT NULL'));
      expect(result.args, isEmpty);
    });
  });

  group('FilterGroup 嵌套', () {
    test('OR 条件分组', () {
      final Query query = Query(
        table: 'users',
        filters: [
          FilterGroup(
            [Filter.eq('name', 'Tom'), Filter.eq('name', 'Jerry')],
            logic: Logic.or,
          ),
        ],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('(name = ? OR name = ?)'));
      expect(result.args, ['Tom', 'Jerry']);
    });

    test('AND + OR 嵌套', () {
      final Query query = Query(
        table: 'users',
        filters: [
          Filter.eq('status', 1),
          FilterGroup(
            [Filter.eq('role', 'admin'), Filter.eq('role', 'super')],
            logic: Logic.or,
          ),
        ],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('status = ?'));
      expect(result.sql, contains('(role = ? OR role = ?)'));
      expect(result.args, [1, 'admin', 'super']);
    });
  });

  group('子查询', () {
    test('Filter.inList 子查询', () {
      final Query subQuery = Query(
        table: 'orders',
        selectFields: ['user_id'],
        filters: [Filter.gt('amount', 100)],
      );
      final Query query = Query(
        table: 'users',
        filters: [Filter.inList('id', subQuery)],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('id IN (SELECT user_id FROM orders'));
      expect(result.sql, contains('amount > ?'));
      expect(result.args, [100]);
    });

    test('Filter.exists 子查询', () {
      final Query subQuery = Query(
        table: 'orders',
        filters: [Filter.eq('status', 'paid')],
      );
      final Query query = Query(
        table: 'users',
        filters: [Filter.exists(subQuery)],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('EXISTS (SELECT * FROM orders'));
      expect(result.args, ['paid']);
    });
  });

  group('ORDER BY', () {
    test('多字段排序', () {
      final Query query = Query(
        table: 'users',
        orderKeys: [Order('age', desc: true), Order('name')],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('ORDER BY age DESC, name ASC'));
    });
  });

  group('GROUP BY + HAVING', () {
    test('分组聚合', () {
      final Query query = Query(
        table: 'users',
        selectFields: ['dept', 'COUNT(*) as cnt'],
        groupBy: ['dept'],
        having: [Filter.gt('cnt', 5)],
      );
      final ({String sql, List<dynamic> args}) result = query.toSql();
      expect(result.sql, contains('GROUP BY dept'));
      expect(result.sql, contains('HAVING cnt > ?'));
      expect(result.args, [5]);
    });
  });
}
