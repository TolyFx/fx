import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/model/paginate.dart';

/// Host 注册配置
class HostOptions {
  final Interceptor? repInterceptor;
  final PaginateParser paginateParser;
  final bool enableLog;

  const HostOptions({
    this.repInterceptor,
    this.paginateParser = const DefaultPaginateParser(),
    this.enableLog = kDebugMode,
  });
}
