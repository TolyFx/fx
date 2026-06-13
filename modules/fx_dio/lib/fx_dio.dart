library fx_dio;

export 'package:dio/dio.dart'
    show Dio, Response, Options, BaseOptions, DioException, DioExceptionType;

export 'package:fx_exception/fx_exception.dart';

/// core
export 'src/core/core.dart';

/// client — dio 实现层
export 'src/client/fx_dio.dart';
export 'src/client/host/host.dart';
export 'src/client/host/host_options.dart';
export 'src/client/host/client_mixin.dart';
