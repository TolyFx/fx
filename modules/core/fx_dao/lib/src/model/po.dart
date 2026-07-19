import 'package:sqflite/sqflite.dart';

abstract class Po {
  Map<String, dynamic> toJson();
}

sealed class InsertParam {
  final String? nullColumnHack;

  final ConflictAlgorithm? conflictAlgorithm;

  const InsertParam({
    this.nullColumnHack,
    this.conflictAlgorithm,
  });
}

class CustomInsert extends InsertParam {
  const CustomInsert({
    super.nullColumnHack,
    super.conflictAlgorithm,
  });
}

class TransactionInsert extends InsertParam {
  final bool? exclusive;

  const TransactionInsert({
    super.nullColumnHack,
    super.conflictAlgorithm,
    this.exclusive,
  });
}

class BatchInsert extends InsertParam {
  final bool? exclusive;
  final bool? noResult;
  final bool? continueOnError;
  const BatchInsert({
    this.continueOnError,
    this.noResult,
    this.exclusive,
    super.nullColumnHack,
    super.conflictAlgorithm,
  });
}

//    String? nullColumnHack,
//     ConflictAlgorithm? conflictAlgorithm,
