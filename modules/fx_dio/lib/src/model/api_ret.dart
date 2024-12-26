import '../exception/trace.dart';

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

class Paginate {
  final int total;
  final int currentPage;
  final int perPage;
  final int lastPage;
  final bool pageMore;

  const Paginate({
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.pageMore,
  });

  factory Paginate.fromMap(dynamic map) {
    return Paginate(
      total: map['total'] ?? 0,
      currentPage: map['current_page'] ?? 0,
      perPage: map['per_page'] ?? 0,
      lastPage: map['last_page'] ?? 0,
      pageMore: map['page_more'] ?? false,
    );
  }
}

class ApiFail<T> extends ApiRet<T> {
  @override
  final Trace trace;

  ApiFail({
    required this.trace,
  });

  // factory ApiFail.code(
  //     Code code, {
  //       dynamic data,
  //       String? msg,
  //     }) {
  //   if (code is AppCode) {
  //     return ApiFail(
  //         error: AppError.code(code, message: msg ?? '', data: data));
  //   }
  //   if (code is ApiCode) {
  //     return ApiFail(
  //         error: NetworkError.code(code, message: msg ?? '', data: data));
  //   }
  //   return ApiFail(
  //       error: AppError.code(AppCode.unknown, message: msg ?? '', data: data));
  // }

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
