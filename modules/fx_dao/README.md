# fx_dao

Flutter 跨平台 SQLite DAO 框架，简化数据库操作和版本迁移。

## 特性

-  **全平台支持** - iOS、Android、Windows、Linux、macOS
-  **自动迁移** - 内置版本升级机制
-  **类型安全** - 泛型 DAO 提供类型安全的 CRUD
-  **强大查询** - 支持子查询、分组、聚合、分页
-  **批量操作** - 支持 Batch 和 Transaction 批量插入

## 安装

`yaml
dependencies:
  fx_dao:
    git:
      url: https://github.com/TolyFx/fx.git
      path: modules/fx_dao
`

## 快速开始

### 1. 定义数据模型 (Po)

`dart
class UserPo extends Po {
  final String id;
  final String name;
  final int age;

  UserPo({required this.id, required this.name, required this.age});

  factory UserPo.fromJson(Map<String, dynamic> json) => UserPo(
    id: json['id'],
    name: json['name'],
    age: json['age'],
  );

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age};
}
`

### 2. 定义 DAO

`dart
class UserDao extends ValueDao<UserPo> {
  @override
  String get name => 'user';

  @override
  String get createSql => '''
    CREATE TABLE user (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age INTEGER DEFAULT 0
    )
  ''';

  @override
  Convertor<UserPo> get convertor => (data) => UserPo.fromJson(data);
}
`

### 3. 定义数据库

`dart
class AppDb extends FxDb {
  @override
  int get version => 1;

  @override
  String get dbname => 'app.db';

  @override
  Iterable<DbTable> get tables => [UserDao()];

  @override
  Iterable<(int, MigrationOperation)> get migrations => [];
}
`

### 4. 使用

`dart
final db = AppDb();
await db.open();

// 获取 DAO
final userDao = db.call<UserDao>();

// 插入
await userDao.insert(UserPo(id: '1', name: 'Tom', age: 18));

// 批量插入
await userDao.insertAll([
  UserPo(id: '2', name: 'Jerry', age: 20),
  UserPo(id: '3', name: 'Spike', age: 25),
]);

// 查询全部
List<UserPo> users = await userDao.query();

// 条件查询
List<UserPo> adults = await userDao.query(Query(
  filters: [Filter.gte('age', 18)],
  orderKeys: [Order('age', desc: true)],
  pageSize: 10,
));

// 关闭
await db.close();
`

## 查询 API

### Filter 操作符

`dart
Filter.eq('name', 'Tom')       // name = 'Tom'
Filter.ne('name', 'Tom')       // name != 'Tom'
Filter.gt('age', 18)           // age > 18
Filter.gte('age', 18)          // age >= 18
Filter.lt('age', 30)           // age < 30
Filter.lte('age', 30)          // age <= 30
Filter.like('name', 'T')       // name LIKE '%T%'
Filter.inList('id', ['1','2']) // id IN ('1', '2')
Filter.between('age', 18, 30)  // age BETWEEN 18 AND 30
Filter.isNull('name')          // name IS NULL
Filter.isNotNull('name')       // name IS NOT NULL
`

### 分组查询

`dart
// OR 条件
Query(filters: [
  FilterGroup([
    Filter.eq('name', 'Tom'),
    Filter.eq('name', 'Jerry'),
  ], logic: Logic.or),
])
// WHERE (name = 'Tom' OR name = 'Jerry')
`

### 子查询

`dart
Filter.inList('dept_id', Query(
  table: 'department',
  selectFields: ['id'],
  filters: [Filter.eq('active', 1)],
))
// dept_id IN (SELECT id FROM department WHERE active = 1)
`

## 数据库迁移

`dart
class AppDb extends FxDb {
  @override
  int get version => 2;  // 升级版本号

  @override
  Iterable<(int, MigrationOperation)> get migrations => [
    (2, (db) async {
      await db.execute('ALTER TABLE user ADD COLUMN email TEXT');
    }),
  ];
}
`

## 跨平台原理

x_dao 通过以下方式实现跨平台：

| 平台 | 实现 |
|------|------|
| iOS / Android | sqflite (原生 SQLite) |
| Windows / Linux | sqflite_common_ffi (FFI 绑定) |
| macOS | sqflite_common_ffi |
| Web | sqflite_common_ffi_web (IndexedDB) |

平台检测在 DbOpenMixin.beforeOpen() 中自动完成：

`dart
void beforeOpen() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
`

## 架构

`

   FxDb        数据库实例，管理表和迁移

  DbOpenMixin  跨平台打开数据库

  DbStore      数据库抽象接口

       
       

 ValueDao<T>   泛型 DAO，提供 CRUD

   DbTable     表定义 (name, createSql)

 HasDatabase   持有 Database 引用

       
       

     Po        持久化对象 (toJson)

`

## License

MIT
