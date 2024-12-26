import 'code/api_code.dart';
import 'code/app_code.dart';
import 'code/code.dart';

mixin Trace {
  Code get code;

  String? get message;

  StackTrace get stack;
}

class NetworkError with Trace implements Exception {
  @override
  final ApiCode code;

  @override
  final String message;

  @override
  final StackTrace stack;

  NetworkError(this.code, this.message, this.stack);

  NetworkError.code(
    this.code, {
    this.message = '',
    required this.stack,
  });

  bool get isInvalid => code == ApiCode.invalid;

  @override
  String toString() {
    return "NetworkError: $code, $message, $stack";
  }
}

class AppError with Trace implements Exception {
  @override
  final AppCode code;

  @override
  final String message;

  @override
  final StackTrace stack;

  AppError(this.code, this.message, this.stack);

  AppError.code(
    this.code, {
    this.message = '',
    required this.stack,
  });

  @override
  String toString() {
    return "AppError: $code, $message, $stack";
  }
}
