import 'package:fx_dao/src/database/has_database.dart';
import 'package:fx_dao/src/table/db_table.dart';

import '../model/query_args.dart';

abstract class Dao<T> with HasDatabase, DbTable {
  Future<List<T>> query({QueryArgs args = const QueryArgs()});

  Future<T> queryById(String id);

  Future<int> deleteById(String? id);

  Future<int> insert(T frame);

  Future<int> update(String id, T frame);
}


