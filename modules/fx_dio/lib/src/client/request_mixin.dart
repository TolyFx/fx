import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fx_dio/src/exception/exception_handler.dart';
import 'package:fx_dio/src/exception/trace.dart';

import '../../fx_dio.dart';
import '../model/api_ret.dart';
import 'convertor.dart';

abstract class RequestAble {
  Future<ApiRet<T>> request<T>(
    Host host,
    String path, {
    required DataConvertor<T> convertor,
    required DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });
}

mixin DioRequestMixin on TraceMixin implements RequestAble {
  Dio find(Host host);

  @override
  Future<ApiRet<T>> request<T>(
    Host host,
    String path, {
    required DataConvertor<T> convertor,
    required DecryptConvertor? decryptConvertor,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    ApiRet<T> result;

    try {
      Response rep = await find(host).request(
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
          if (decryptConvertor != null) {
            repData = jsonDecode(decryptConvertor(repData));
          }
          T ret = convertor(repData);
          Paginate? paginate;

          if (repData is Map) {
            dynamic paginateData = repData['paginate'];
            if (paginateData != null) {
              paginate = Paginate.fromMap(paginateData);
            }
          }
          result = ApiOK(ret, paginate: paginate);
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
          RequestErrorCode.emptyData,
          'request empty data',
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
}
