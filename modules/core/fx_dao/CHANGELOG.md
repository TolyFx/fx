# Changelog

## 0.0.4

- Fixed: 数据库迁移边界条件错误（`version == newVersion` 的迁移不执行）
- Fixed: 迁移按版本号排序执行，不再依赖注册顺序
- Added: DbMigration 单元测试 5 个

## 0.0.3+5

- Fixed: FilterGroup OR 逻辑 bug（OR 条件被错误当作 AND 执行）
- Fixed: `DbOpenMixin.open()` 加重入保护，多次调用不再覆盖连接
- Added: 单元测试 21 个（Query 构建器全操作符 + SnowflakeId）
- Fixed: 静态分析 info（if 语句大括号）

## 0.0.3+4

- Added: Query 构建器支持子查询（inList/exists/notExists 子查询）
- Added: FilterGroup 嵌套条件分组（AND/OR）

## 0.0.3+3

- Added: ValueDao 泛型 DAO（query/queryOne/queryById/deleteById/insert/insertAll）

## 0.0.3+1

- Added: BatchInsert / TransactionInsert 批量插入策略

## 0.0.2

- Added: insert / insertAll / queryById / update 基础 CRUD

## 0.0.1

- Added: FxDb / DbOpenMixin / DbTable / DbMigration 核心架构
- Added: Po 抽象 + SnowflakeIdGenerator
- Added: 跨平台支持（sqflite + sqflite_common_ffi）
