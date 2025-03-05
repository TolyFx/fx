import 'package:fx_dao/fx_dao.dart';

typedef Convertor<T> = T Function(Map<String, Object?> data);
typedef ConvertorList<T> = T Function(List<Map<String, Object?>> data);

abstract class Dao<T extends Po> with HasDatabase, DbTable {
  Future<List<T>> query({QueryArgs args = const QueryArgs()}) async {
    var (String where, List<Object?>? arguments) = args.parserSql;
    List<Map<String, Object?>> data =
        await database.rawQuery('SELECT FROM $name $where', arguments);
    return data.map<T>(convertor).toList();
  }

  Convertor<T> get convertor;

  Future<int> clear() => database.delete(name);

  Future<T> queryById(
    String id,
    String idColumn,
  ) async {
    List<Map<String, Object?>> data =
        await database.query(name, where: '$idColumn = ?', whereArgs: [id]);
    if (data.isEmpty) {
      throw 'no data with $idColumn = $id';
    }
    if (data.length > 1) {
      throw 'data has more with $idColumn = $id';
    }
    return convertor(data.first);
  }

  Future<int> deleteById(String? id, String idColumn) {
    return database.delete(name, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> insert(
    T frame, {
    CustomInsert? param,
  }) =>
      database.insert(
        name,
        frame.toJson(),
        nullColumnHack: param?.nullColumnHack,
        conflictAlgorithm: param?.conflictAlgorithm,
      );

  Future<bool> insertAll(
    List<T> frames, {
    InsertParam param = const BatchInsert(),
  }) async {
    return switch (param) {
      CustomInsert() => _insertAll(frames, param),
      TransactionInsert() => _insertAllWithTransaction(frames, param),
      BatchInsert() => _insertAllWithBatch(frames, param),
    };
  }

  Future<int> update(String id, T frame);

  Future<bool> _insertAll(List<T> frames, CustomInsert param) async {
    for (T frame in frames) {
      await insert(frame, param: param);
    }
    return true;
  }

  Future<bool> _insertAllWithBatch(List<T> frames, BatchInsert param) async {
    // 使用 Batch 来提高批量插入的效率
    // 创建一个批量操作对象
    Batch batch = database.batch();
    for (T frame in frames) {
      batch.insert(
        name,
        frame.toJson(),
        nullColumnHack: param.nullColumnHack,
        conflictAlgorithm: param.conflictAlgorithm,
      );
    }
    // 执行批量操作
    await batch.commit(noResult: true);
    return true;
  }

  Future<bool> _insertAllWithTransaction(
      List<T> frames, TransactionInsert param) async {
    // 使用事务来提高批量插入的效率
    await database.transaction((Transaction txn) async {
      // 批量插入表数据
      for (T frame in frames) {
        await txn.insert(
          name,
          frame.toJson(),
          nullColumnHack: param.nullColumnHack,
          conflictAlgorithm: param.conflictAlgorithm,
        );
      }
    });
    return true;
  }
}
