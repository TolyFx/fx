/// 查询操作符
enum QueryOp {
  eq, // =
  ne, // !=
  gt, // >
  lt, // <
  gte, // >=
  lte, // <=
  like, // LIKE
  notLike, // NOT LIKE
  inList, // IN
  notInList, // NOT IN
  between, // BETWEEN
  notBetween, // NOT BETWEEN
  isNull, // IS NULL
  isNotNull, // IS NOT NULL
  exists, // EXISTS (子查询)
  notExists, // NOT EXISTS (子查询)
  glob, // GLOB (SQLite)
  regexp, // REGEXP (部分数据库)
}

/// 逻辑运算符（用于分组）
enum Logic { and, or }

/// 查询条件基类
abstract class BaseFilter {}

/// 单个查询条件（支持 value 为 Query 子查询）
class Filter extends BaseFilter {
  final String key; // 列名
  final QueryOp op; // 操作符
  final dynamic value; // 值（可为基本类型、List、区间、Query）
  final dynamic value2; // 用于 between 的第二个值

  Filter.eq(this.key, this.value)
      : op = QueryOp.eq,
        value2 = null;
  Filter.ne(this.key, this.value)
      : op = QueryOp.ne,
        value2 = null;
  Filter.gt(this.key, this.value)
      : op = QueryOp.gt,
        value2 = null;
  Filter.lt(this.key, this.value)
      : op = QueryOp.lt,
        value2 = null;
  Filter.gte(this.key, this.value)
      : op = QueryOp.gte,
        value2 = null;
  Filter.lte(this.key, this.value)
      : op = QueryOp.lte,
        value2 = null;
  Filter.like(this.key, this.value)
      : op = QueryOp.like,
        value2 = null;
  Filter.notLike(this.key, this.value)
      : op = QueryOp.notLike,
        value2 = null;
  Filter.inList(this.key, dynamic values)
      : op = QueryOp.inList,
        value = values,
        value2 = null;
  Filter.notInList(this.key, dynamic values)
      : op = QueryOp.notInList,
        value = values,
        value2 = null;
  Filter.between(this.key, this.value, this.value2) : op = QueryOp.between;
  Filter.notBetween(this.key, this.value, this.value2)
      : op = QueryOp.notBetween;
  Filter.isNull(this.key)
      : op = QueryOp.isNull,
        value = null,
        value2 = null;
  Filter.isNotNull(this.key)
      : op = QueryOp.isNotNull,
        value = null,
        value2 = null;
  Filter.exists(Query subQuery)
      : key = '',
        op = QueryOp.exists,
        value = subQuery,
        value2 = null;
  Filter.notExists(Query subQuery)
      : key = '',
        op = QueryOp.notExists,
        value = subQuery,
        value2 = null;
  Filter.glob(this.key, this.value)
      : op = QueryOp.glob,
        value2 = null;
  Filter.regexp(this.key, this.value)
      : op = QueryOp.regexp,
        value2 = null;
}

/// 条件分组（支持 AND/OR 嵌套）
class FilterGroup extends BaseFilter {
  final List<BaseFilter> filters;
  final Logic logic;
  FilterGroup(this.filters, {this.logic = Logic.and});
}

/// 排序条件
class Order {
  final String key; // 列名
  final bool desc; // 是否降序

  Order(this.key, {this.desc = false});

  @override
  String toString() => '$key ${desc ? 'DESC' : 'ASC'}';
}

/// 查询参数封装，支持多条件、排序、分页、分组、聚合、字段选择、子查询
class Query {
  String? table;
  final List<String>? selectFields; // 查询字段
  final List<BaseFilter>? filters; // WHERE 条件
  final List<String>? groupBy; // GROUP BY 字段
  final List<BaseFilter>? having; // HAVING 条件
  final int page; // 页码（从1开始）
  final int pageSize; // 每页数量
  final List<Order>? orderKeys; // 排序条件

  Query({
    this.table,
    this.selectFields,
    this.filters,
    this.groupBy,
    this.having,
    this.page = 1,
    this.pageSize = 20,
    this.orderKeys,
  });

  /// 生成SQL片段和参数列表
  ({String sql, List<dynamic> args}) toSql() {
    final select = _selectClause();
    final whereResult = _filterClause(filters);
    final groupByClause = _groupByClause();
    final havingResult = _filterClause(having, isHaving: true);
    final orderBy = _orderByClause();
    final limitOffset = _limitOffsetClause();

    final buffer = StringBuffer();
    buffer.write(select);
    if (whereResult.sql.isNotEmpty) buffer.write(' WHERE ${whereResult.sql}');
    if (groupByClause.isNotEmpty) buffer.write(' GROUP BY $groupByClause');
    if (havingResult.sql.isNotEmpty)
      buffer.write(' HAVING ${havingResult.sql}');
    if (orderBy.isNotEmpty) buffer.write(' ORDER BY $orderBy');
    if (limitOffset.isNotEmpty) buffer.write(' $limitOffset');

    // 合并参数
    final args = <dynamic>[];
    args.addAll(whereResult.args);
    args.addAll(havingResult.args);

    return (sql: buffer.toString().trim(), args: args);
  }

  /// 生成 SELECT 子句
  String _selectClause() {
    if (selectFields == null || selectFields!.isEmpty) {
      return 'SELECT * FROM $table';
    }
    return 'SELECT ${selectFields!.join(', ')} FROM $table';
  }

  /// 递归生成 WHERE/HAVING 子句和参数，支持子查询和所有操作符
  ({String sql, List<dynamic> args}) _filterClause(List<BaseFilter>? filters,
      {bool isHaving = false}) {
    if (filters == null || filters.isEmpty) return (sql: '', args: []);
    final List<String> sqlParts = [];
    final List<dynamic> args = [];
    for (final f in filters) {
      if (f is Filter) {
        switch (f.op) {
          case QueryOp.eq:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} = (${sub.sql})');
              args.addAll(sub.args);
            } else {
              sqlParts.add('${f.key} = ?');
              args.add(f.value);
            }
            break;
          case QueryOp.ne:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} != (${sub.sql})');
              args.addAll(sub.args);
            } else {
              sqlParts.add('${f.key} != ?');
              args.add(f.value);
            }
            break;
          case QueryOp.gt:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} > (${sub.sql})');
              args.addAll(sub.args);
            } else {
              sqlParts.add('${f.key} > ?');
              args.add(f.value);
            }
            break;
          case QueryOp.lt:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} < (${sub.sql})');
              args.addAll(sub.args);
            } else {
              sqlParts.add('${f.key} < ?');
              args.add(f.value);
            }
            break;
          case QueryOp.gte:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} >= (${sub.sql})');
              args.addAll(sub.args);
            } else {
              sqlParts.add('${f.key} >= ?');
              args.add(f.value);
            }
            break;
          case QueryOp.lte:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} <= (${sub.sql})');
              args.addAll(sub.args);
            } else {
              sqlParts.add('${f.key} <= ?');
              args.add(f.value);
            }
            break;
          case QueryOp.like:
            sqlParts.add('${f.key} LIKE ?');
            args.add('%${f.value}%');
            break;
          case QueryOp.notLike:
            sqlParts.add('${f.key} NOT LIKE ?');
            args.add('%${f.value}%');
            break;
          case QueryOp.glob:
            sqlParts.add('${f.key} GLOB ?');
            args.add(f.value);
            break;
          case QueryOp.regexp:
            sqlParts.add('${f.key} REGEXP ?');
            args.add(f.value);
            break;
          case QueryOp.inList:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} IN (${sub.sql})');
              args.addAll(sub.args);
            } else {
              final placeholders =
                  List.filled((f.value as List).length, '?').join(', ');
              sqlParts.add('${f.key} IN ($placeholders)');
              args.addAll(f.value);
            }
            break;
          case QueryOp.notInList:
            if (f.value is Query) {
              final sub = (f.value as Query).toSql();
              sqlParts.add('${f.key} NOT IN (${sub.sql})');
              args.addAll(sub.args);
            } else {
              final placeholders =
                  List.filled((f.value as List).length, '?').join(', ');
              sqlParts.add('${f.key} NOT IN ($placeholders)');
              args.addAll(f.value);
            }
            break;
          case QueryOp.between:
            if (f.value is Query && f.value2 is Query) {
              final sub1 = (f.value as Query).toSql();
              final sub2 = (f.value2 as Query).toSql();
              sqlParts.add('${f.key} BETWEEN (${sub1.sql}) AND (${sub2.sql})');
              args.addAll(sub1.args);
              args.addAll(sub2.args);
            } else if (f.value is Query) {
              final sub1 = (f.value as Query).toSql();
              sqlParts.add('${f.key} BETWEEN (${sub1.sql}) AND ?');
              args.addAll(sub1.args);
              args.add(f.value2);
            } else if (f.value2 is Query) {
              final sub2 = (f.value2 as Query).toSql();
              sqlParts.add('${f.key} BETWEEN ? AND (${sub2.sql})');
              args.add(f.value);
              args.addAll(sub2.args);
            } else {
              sqlParts.add('${f.key} BETWEEN ? AND ?');
              args.add(f.value);
              args.add(f.value2);
            }
            break;
          case QueryOp.notBetween:
            sqlParts.add('${f.key} NOT BETWEEN ? AND ?');
            args.add(f.value);
            args.add(f.value2);
            break;
          case QueryOp.isNull:
            sqlParts.add('${f.key} IS NULL');
            break;
          case QueryOp.isNotNull:
            sqlParts.add('${f.key} IS NOT NULL');
            break;
          case QueryOp.exists:
            final sub = (f.value as Query).toSql();
            sqlParts.add('EXISTS (${sub.sql})');
            args.addAll(sub.args);
            break;
          case QueryOp.notExists:
            final sub = (f.value as Query).toSql();
            sqlParts.add('NOT EXISTS (${sub.sql})');
            args.addAll(sub.args);
            break;
        }
      } else if (f is FilterGroup) {
        final sub = _filterClause(f.filters, isHaving: isHaving);
        if (sub.sql.isNotEmpty) {
          sqlParts.add('(${sub.sql})');
          args.addAll(sub.args);
        }
      }
    }
    // 逻辑运算符
    Logic logic = Logic.and;
    if (filters.length == 1 && filters.first is FilterGroup) {
      logic = (filters.first as FilterGroup).logic;
    } else if (filters is FilterGroup) {
      logic = (filters as FilterGroup).logic;
    }
    final joiner = logic == Logic.or ? ' OR ' : ' AND ';
    return (sql: sqlParts.join(joiner), args: args);
  }

  /// 生成 GROUP BY 子句
  String _groupByClause() {
    if (groupBy == null || groupBy!.isEmpty) return '';
    return groupBy!.join(', ');
  }

  /// 生成 ORDER BY 子句
  String _orderByClause() {
    if (orderKeys == null || orderKeys!.isEmpty) return '';
    return orderKeys!.map((o) => o.toString()).join(', ');
  }

  /// 生成 LIMIT OFFSET 子句
  String _limitOffsetClause() {
    if (pageSize <= 0) return '';
    final offset = (page - 1) * pageSize;
    return 'LIMIT $pageSize OFFSET $offset';
  }
}
