// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:fx_dao/fx_dao.dart';
//
import 'package:fx_dao/fx_dao.dart';

void main() {
  simpleTest2();
}

void simpleTest2() {
  final subQuery = Query(
    table: 'orders',
    selectFields: ['user_id'],
    filters: [Filter.gt('amount', 100)],
  );

  final mainQuery = Query(
    table: 'users',
    filters: [
      Filter.inList('id', subQuery),
      Filter.eq('status', 1),
    ],
  );

  final result = mainQuery.toSql();
  final sql = result.sql;
  final params = result.args;
  print(sql);
  print(params);
}

void simpleTest() {
  final args = Query(
    table: 'users',
    selectFields: ['id', 'name', 'COUNT(*) as cnt'],
    filters: [
      Filter.eq('status', 1),
      Filter.like('name', '张三'),
      Filter.inList('type', [1, 2, 3]),
      Filter.between('age', 18, 60),
      FilterGroup(
        [
          Filter.like('email', 'zhangsan'),
          Filter.eq('job', '编程'),
        ],
        logic: Logic.or,
      ),
      Filter.eq('status', 1),
    ],
    orderKeys: [
      Order('id', desc: true),
      Order('age', desc: true),
    ],
    groupBy: ['name'],
    having: [Filter.gt('cnt', 1)],
    page: 2,
    pageSize: 10,
  );

  final result = args.toSql();
  final sql = result.sql;
  final params = result.args;

// sql: SELECT * FROM users WHERE status = ? AND name LIKE ? LIMIT 10 OFFSET 0
// params: [1, '%张三%']
  print(sql);
  print(params);
}
