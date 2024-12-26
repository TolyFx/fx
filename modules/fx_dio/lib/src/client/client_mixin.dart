import 'package:dio/dio.dart';
import 'package:fx_dio/fx_dio.dart';

import '../model/api_ret.dart';
import 'convertor.dart';

mixin ClientMixin {
  Host get host;

  Future<ApiRet<T>> post<T>(
    String path, {
    required DataConvertor<T> convertor,
    DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
  }) async {
    return FxDio().request(
      host,
      path,
      data: data,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
      options: checkOptions('POST', options),
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<ApiRet<T>> get<T>(
    String path, {
    required DataConvertor<T> convertor,
    DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return FxDio().request(
      host,
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('GET', options),
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
    );
  }

  Future<ApiRet<T>> put<T>(
    String path, {
    required DataConvertor<T> convertor,
    DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
  }) async {
    return FxDio().request(
      host,
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('PUT', options),
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
    );
  }

  Future<ApiRet<T>> patch<T>(
    String path, {
    required DataConvertor<T> convertor,
    DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return FxDio().request(
      host,
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('PATCH', options),
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
    );
  }

  Future<ApiRet<T>> delete<T>(
      String path, {
        required DataConvertor<T> convertor,
        DecryptConvertor? decryptConvertor,
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return FxDio().request(
      host,
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('DELETE', options),
      cancelToken: cancelToken,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
    );
  }

  Future<ApiRet<T>> head<T>(
      String path, {
        required DataConvertor<T> convertor,
        DecryptConvertor? decryptConvertor,
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return FxDio().request(
      host,
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('HEAD', options),
      cancelToken: cancelToken,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
    );
  }

  static Options checkOptions(String method, Options? options) {
    options ??= Options();
    options.method = method;
    return options;
  }
}
