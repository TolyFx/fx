import 'package:dio/dio.dart';

import '../model/api_auth.dart';

class AuthInterceptor extends InterceptorsWrapper {
  final ApiAuth auth;

  AuthInterceptor({required this.auth});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    options.headers.addAll(await auth.buildHeaders);
    handler.next(options);
  }


}
