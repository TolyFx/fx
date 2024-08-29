import 'dart:async';

import 'package:sqflite/sqflite.dart';

abstract class DbStore {
  Future<String> get dbpath;

  int get version;

  Future<void> onCreate(Database db, int version);

  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion);

  Future<void> close();
}
