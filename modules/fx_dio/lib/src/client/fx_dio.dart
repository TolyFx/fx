import 'package:dio/dio.dart';

import '../exception/exception_handler.dart';
import '../interceptor/auth_interceptor.dart';
import '../interceptor/log_interceptor.dart';
import '../model/api_auth.dart';
import 'host.dart';
import 'request_mixin.dart';

class FxDio with TraceMixin, DioRequestMixin {
  FxDio._();

  static bool kIsDev = false;

  factory FxDio() {
    _instance ??= FxDio._();
    return _instance!;
  }

  static FxDio? _instance;

  final Map<Host, Dio> _dioMap = {};

  void auth<T extends Host>(ApiAuth auth) {
    Iterable<Host> hosts = _dioMap.keys.whereType<T>();
    assert(hosts.length == 1, 'find ${hosts.length} Host, must be 1 ');
    addInterceptors(hosts.first, auth: auth);
  }

  Host call<T extends Host>() {
    Host? host;
    for (Host key in _dioMap.keys) {
      if (key is T) {
        host = key;
      }
    }
    assert(host != null, "Type $T not fond , you should call registerHosts first.");
    return host!;
  }

  Dio operator [](Host host) {
    Dio dio = _dioMap[host] ?? _accept(host);
    return dio;
  }

  void register(Host host, {Interceptor? repInterceptor}) {
    Iterable<Host> hosts = _dioMap.keys.where((e) => e.url == host.url);
    assert(hosts.isEmpty, '${host.runtimeType} already register');
    _accept(host, repInterceptor: repInterceptor);
  }

  void unregister(Host host) {
    _dioMap.remove(host);
  }

  Dio _accept(Host host, {Interceptor? repInterceptor}) {
    if (_dioMap.containsKey(host)) {
      return _dioMap[host]!;
    }
    Dio dio = _createClient(host,repInterceptor: repInterceptor);
    _dioMap[host] = dio;
    return dio;
  }

  void addInterceptors(
    Host host, {
    ApiAuth? auth,
    bool logEnable = false,
    bool repInterceptorEnable = true,
  }) {
    Dio dio = this[host];
    if (auth != null) {
      dio.interceptors.removeWhere((e) => e is AuthInterceptor);
      AuthInterceptor interceptor = AuthInterceptor(auth: auth);
      dio.interceptors.add(interceptor);
    }
    if (logEnable) {
      dio.interceptors.add(HttpLogInterceptor());
    }
  }

  Dio _createClient(Host host, {Interceptor? repInterceptor}) {
    Dio dio = Dio();
    dio.options.baseUrl = host.url(isDev: kIsDev);
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 10);
    dio.options.receiveDataWhenStatusError = true;
    dio.options.validateStatus = (status) {
      return status! > 0;
    };
    if (repInterceptor != null) {
      dio.interceptors.add(repInterceptor);
    }
    return dio;
  }

  @override
  Dio find(Host host) => this[host];
}
