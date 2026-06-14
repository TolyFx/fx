import 'package:fx_exception/fx_exception.dart';
import 'paginate.dart';

sealed class ApiRet<T> {
  String get msg;

  bool get success => this is ApiOK;

  bool get failed => this is ApiFail;

  T get data {
    assert(success, '\n:: when call .data, success must be true.\n$_errorTips');
    return (this as ApiOK<T>).t;
  }

  String get _errorTips =>
      'find error: [code#$code]::\n'
      'message:${trace?.message}\n'
      'error:${trace?.error}\n'
      'stack:${trace?.stack}';

  Paginate? get paginate;

  Trace? get trace => null;

  int? get code => null;
}

class ApiOK<T> extends ApiRet<T> {
  final T t;

  @override
  final String msg;

  @override
  final Paginate? paginate;

  ApiOK(
    this.t, {
    this.paginate,
    this.msg = '',
  });
}

class ApiFail<T> extends ApiRet<T> {
  @override
  final Trace trace;

  ApiFail({
    required this.trace,
  });

  @override
  Paginate? get paginate => null;

  @override
  String get msg {
    if (trace.message != null && trace.message!.isNotEmpty) {
      return trace.message!;
    }
    return trace.error.toString();
  }
}
