import 'package:dio/dio.dart';

import '../../core/host/host.dart';
import '../../core/model/api_ret.dart';
import '../../core/model/convertor.dart';
import '../fx_dio.dart';

/// 为 Host 提供 HTTP 便捷方法
mixin ClientMixin<H extends Host> {
  H get host;

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
      options: FxDio.checkOptions('POST', options),
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
      options: FxDio.checkOptions('GET', options),
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
      options: FxDio.checkOptions('PUT', options),
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
      options: FxDio.checkOptions('PATCH', options),
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
      options: FxDio.checkOptions('DELETE', options),
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
      options: FxDio.checkOptions('HEAD', options),
      cancelToken: cancelToken,
      convertor: convertor,
      decryptConvertor: decryptConvertor,
    );
  }
}
