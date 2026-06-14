import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HttpLogInterceptor extends InterceptorsWrapper {
  final Map<RequestOptions, DateTime> _requestTimes = {};

  // ANSI 颜色码 — macOS/iOS 的控制台不支持 ANSI 转义序列，仅在 Windows 上启用
  static final bool _supportsAnsi = Platform.isWindows;
  static final String _blue = _supportsAnsi ? '\x1B[38;5;12m' : '';
  static final String _green = _supportsAnsi ? '\x1B[38;5;10m' : '';
  static final String _gray = _supportsAnsi ? '\x1B[38;5;245m' : '';
  static final String _red = _supportsAnsi ? '\x1B[38;5;196m' : '';
  static final String _reset = _supportsAnsi ? '\x1B[0m' : '';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimes[options] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    assert(() {
      final duration = _getDuration(response.requestOptions);
      final url =
          '${response.requestOptions.uri.path}${response.requestOptions.uri.hasQuery ? '?${response.requestOptions.uri.query}' : ''}';
      String requestId = '';
      if (response.data is Map && response.data['request_id'] != null) {
        requestId = '${response.data['request_id']}';
      }
      final params = _formatParams(response.requestOptions);
      debugPrint(
        '$_green[${duration}ms] [${response.requestOptions.method}#${response.statusCode} | $requestId]$_reset $_blue$url$_reset$params',
      );
      return true;
    }());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      final duration = _getDuration(err.requestOptions);
      final url =
          '${err.requestOptions.uri.path}${err.requestOptions.uri.hasQuery ? '?${err.requestOptions.uri.query}' : ''}';
      final params = _formatParams(err.requestOptions);
      debugPrint(
        '$_red[${duration}ms] [${err.requestOptions.method}#Error]$_reset $_blue$url$_reset ${err.message}$params',
      );
      return true;
    }());
    handler.next(err);
  }

  int _getDuration(RequestOptions options) {
    final startTime = _requestTimes.remove(options);
    if (startTime == null) return 0;
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  String _formatParams(RequestOptions options) {
    final parts = <String>[];
    if (options.queryParameters.isNotEmpty) {
      parts.add('query: ${options.queryParameters}');
    }
    if (options.data != null) {
      final data = options.data;
      if (data is FormData) {
        final fields = {for (final e in data.fields) e.key: e.value};
        parts.add('body: $fields');
      } else {
        parts.add('body: $data');
      }
    }
    if (parts.isEmpty) return '';
    return '\n  $_gray└─ ${parts.join(', ')}$_reset';
  }
}
