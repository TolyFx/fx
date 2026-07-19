import 'retry_condition.dart';

/// HTTP状态码条件
class HttpStatusCondition implements RetryCondition {
  const HttpStatusCondition(this.statusCodes);
  
  factory HttpStatusCondition.range(int start, int end) {
    return HttpStatusCondition(
      List.generate(end - start + 1, (i) => start + i),
    );
  }
  
  final List<int> statusCodes;

  @override
  bool shouldRetry(Exception exception, int attempt) {
    if (exception is HttpException) {
      return statusCodes.contains(exception.statusCode);
    }
    return false;
  }
}

/// HTTP异常
class HttpException implements Exception {
  const HttpException(this.message, this.statusCode);
  
  final String message;
  final int statusCode;
  
  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}