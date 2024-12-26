// import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart';

class HttpLogInterceptor extends LogInterceptor {
  final Map<Uri, DateTime> _requestDateTimeMap = <Uri, DateTime>{};

  HttpLogInterceptor({bool reqBody = true, bool resBody = true})
      : super(requestBody: reqBody, responseBody: resBody);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log.info('onRequest url:${options.uri}');
    // Log.info('onRequest host:${options.uri.host}, path:${options.uri.path}');
    //
    // if (request) {
    //   Log.info('onRequest method: ${options.method}');
    // }
    // if (requestHeader) {
    //   Log.info('onRequest headers:');
    //   options.headers.forEach((key, dynamic v) => Log.info(' $key: $v'));
    // }
    // if (requestBody) {
    //   Log.info('onRequest requestBody: ${options.data.toString()}');
    // }
    // _requestDateTimeMap.putIfAbsent(options.uri, () {
    //   return DateTime.now();
    // });
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log.error("request onError", err);
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log.info('onReponse uri: ${response.requestOptions.uri.path}');
    // Log.info('onReponse uri: ${response.requestOptions.uri}');
    // if (responseHeader) {
    //   Log.info('onReponse statusCode: ${response.statusCode}');
    // }
    // if (responseBody) {
    //   Log.info('onReponse Response data:');
    //   Log.info('${response.toString()}');
    // }
    // Log.info(
    //     "http request ${DateTime.now().difference(_requestDateTimeMap[response.requestOptions.uri] ?? DateTime.now())}");
    handler.next(response);
  }
}
