import 'retry_condition.dart';

/// 异常条件
class ExceptionCondition<T extends Exception> implements RetryCondition {
  const ExceptionCondition();

  // factory ExceptionCondition.anyOf(List<Type> exceptionTypes) {
  //   return AnyExceptionCondition(exceptionTypes);
  // }

  @override
  bool shouldRetry(Exception exception, int attempt) {
    return exception is T;
  }
}

/// 多种异常类型条件
class AnyExceptionCondition implements RetryCondition {
  const AnyExceptionCondition(this.exceptionTypes);

  final List<Type> exceptionTypes;

  @override
  bool shouldRetry(Exception exception, int attempt) {
    return exceptionTypes.any((type) => exception.runtimeType == type);
  }
}
