/// 重试回调函数类型
typedef RetryCallback = void Function(
  int attempt,
  Exception exception,
  Duration delay,
);