import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:fx_exception/fx_exception.dart';

import '../core/host/host.dart';
import '../core/model/api_auth.dart';
import '../core/model/api_ret.dart';
import '../core/model/convertor.dart';
import '../core/model/paginate.dart';
import 'host/host_options.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/log_interceptor.dart';

class _HostEntry {
  final Dio dio;
  final HostOptions options;
  bool enableLog;

  _HostEntry({
    required this.dio,
    required this.options,
  }) : enableLog = options.enableLog;
}

class FxDio with TraceMixin {
  FxDio._() {
    addTraceListener(kDefaultErrorHandler);
  }

  factory FxDio() {
    _instance ??= FxDio._();
    return _instance!;
  }

  static FxDio? _instance;

  final Map<Host, _HostEntry> _hostMap = {};

  // ==================== 公开 API ====================

  /// 为指定 Host 类型注册认证
  void auth<T extends Host>(ApiAuth auth) {
    Iterable<Host> hosts = _hostMap.keys.whereType<T>();
    assert(hosts.length == 1, 'find ${hosts.length} Host, must be 1 ');
    addInterceptors(hosts.first, auth: auth);
  }

  /// 按类型查找已注册的 Host
  Host call<T extends Host>() {
    Host? host;
    for (Host key in _hostMap.keys) {
      if (key is T) {
        host = key;
      }
    }
    assert(host != null, "Type $T not found, you should call register first.");
    return host!;
  }

  /// 通过 Host 获取对应 Dio 实例
  Dio operator [](Host host) {
    return (_hostMap[host] ?? _accept(host)).dio;
  }

  /// 注册 Host
  void register(Host host, {HostOptions options = const HostOptions()}) {
    assert(!_hostMap.containsKey(host), '${host.runtimeType} already registered');
    _accept(host, options: options);
  }

  /// 注销 Host
  void unregister(Host host) {
    _hostMap.remove(host)?.dio.close();
  }

  /// 运行时更新域名（保留拦截器等状态），未注册时自动注册
  void rebase<T extends Host>(Host host, {HostOptions? options}) {
    _HostEntry? entry;
    for (Host key in _hostMap.keys) {
      if (key is T) {
        entry = _hostMap[key];
      }
    }
    if (entry != null) {
      entry.dio.options.baseUrl = host.url;
    } else {
      register(host, options: options ?? const HostOptions());
    }
  }

  /// 按 Host 类型动态调整超时
  void setTimeout<T extends Host>({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    Host host = this<T>();
    Dio? dio = _hostMap[host]?.dio;
    if (dio != null) {
      if (connectTimeout != null) dio.options.connectTimeout = connectTimeout;
      if (receiveTimeout != null) dio.options.receiveTimeout = receiveTimeout;
      if (sendTimeout != null) dio.options.sendTimeout = sendTimeout;
    }
  }

  /// 动态开启/关闭指定 Host 的日志
  void setLog<T extends Host>(bool enable) {
    Host host = this<T>();
    _HostEntry? entry = _hostMap[host];
    if (entry == null) return;
    if (enable && !entry.enableLog) {
      entry.dio.interceptors.add(HttpLogInterceptor());
    } else if (!enable && entry.enableLog) {
      entry.dio.interceptors.removeWhere((e) => e is HttpLogInterceptor);
    }
    entry.enableLog = enable;
  }

  // ==================== 请求 ====================

  static Options checkOptions(String method, Options? options) {
    options ??= Options();
    options.method = method;
    return options;
  }

  Future<ApiRet<T>> request<T>(
    Host host,
    String path, {
    required DataConvertor<T> convertor,
    DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    ApiRet<T> result;

    try {
      Response<dynamic> rep = await this[host].request(
        path,
        data: data,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: options,
      );
      dynamic repData = rep.data;
      if (repData != null) {
        try {
          result = _convertBody<T>(host, repData, convertor, decryptConvertor);
        } catch (error, stack) {
          result = ApiFail(
            trace: RequestException(
              RequestErrorCode.convert,
              'convert exception',
              error,
              stack,
            ),
          );
        }
      } else {
        result = ApiFail(
          trace: RequestException(
              RequestErrorCode.emptyData, 'request empty data'),
        );
      }
    } catch (error, stack) {
      result = ApiFail(
        trace: RequestException(
          RequestErrorCode.exception,
          'request exception',
          error,
          stack,
        ),
      );
    }

    if (result.failed) {
      notifyTrace((result as ApiFail).trace);
    }
    return result;
  }

  // ==================== 内部 ====================

  ApiOK<T> _convertBody<T>(
    Host host,
    dynamic data,
    DataConvertor<T> convertor,
    DecryptConvertor? decryptConvertor,
  ) {
    if (decryptConvertor != null && data is String) {
      data = jsonDecode(decryptConvertor(data));
    } else if (decryptConvertor != null && data is Map) {
      dynamic value = data['data'];
      if (value is String && value.isNotEmpty) {
        data['data'] = jsonDecode(decryptConvertor(value));
      }
    }
    T ret = convertor(data);
    PaginateParser parser =
        _hostMap[host]?.options.paginateParser ?? const DefaultPaginateParser();
    Paginate? paginate = parser.parse(data);
    return ApiOK<T>(ret, paginate: paginate);
  }

  void addInterceptors(Host host, {ApiAuth? auth}) {
    Dio dio = this[host];
    if (auth != null) {
      dio.interceptors.removeWhere((e) => e is AuthInterceptor);
      dio.interceptors.add(AuthInterceptor(auth: auth));
    }
  }

  _HostEntry _accept(Host host, {HostOptions options = const HostOptions()}) {
    Dio dio = _createDio(host, options: options);
    _HostEntry entry = _HostEntry(dio: dio, options: options);
    _hostMap[host] = entry;
    return entry;
  }

  Dio _createDio(Host host, {required HostOptions options}) {
    Dio dio = Dio();
    dio.options.baseUrl = host.url;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 10);
    dio.options.receiveDataWhenStatusError = true;
    dio.options.validateStatus = (status) => status! > 0;
    if (options.enableLog) {
      dio.interceptors.add(HttpLogInterceptor());
    }
    if (options.repInterceptor != null) {
      dio.interceptors.add(options.repInterceptor!);
    }
    return dio;
  }
}
