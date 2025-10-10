# API 参考文档

## FxRetry 类

### 静态方法

#### execute<T>
执行带重试的异步操作。

```dart
static Future<T> execute<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  RetryPolicy? policy,
  RetryCondition? condition,
  Duration? timeout,
  RetryCallback? onRetry,
})
```

**参数:**
- `operation`: 要执行的异步操作
- `maxAttempts`: 最大重试次数 (默认: 3)
- `policy`: 重试策略 (默认: FixedDelayPolicy(1秒))
- `condition`: 重试条件 (默认: 所有异常都重试)
- `timeout`: 总体超时时间
- `onRetry`: 重试回调函数

**返回:** 操作结果

**异常:**
- `RetryExhaustedException`: 重试次数耗尽
- `RetryTimeoutException`: 操作超时

#### builder<T>
创建重试构建器。

```dart
static RetryBuilder<T> builder<T>()
```

**返回:** RetryBuilder 实例

## RetryBuilder 类

### 方法

#### maxAttempts
设置最大重试次数。

```dart
RetryBuilder<T> maxAttempts(int attempts)
```

#### fixedDelay
设置固定延迟策略。

```dart
RetryBuilder<T> fixedDelay(Duration delay)
```

#### exponentialBackoff
设置指数退避策略。

```dart
RetryBuilder<T> exponentialBackoff({
  Duration initialDelay = const Duration(seconds: 1),
  double multiplier = 2.0,
  Duration? maxDelay,
})
```

#### linearBackoff
设置线性增长策略。

```dart
RetryBuilder<T> linearBackoff({
  Duration initialDelay = const Duration(seconds: 1),
  Duration increment = const Duration(seconds: 1),
  Duration? maxDelay,
})
```

#### retryOn<E>
设置重试异常类型。

```dart
RetryBuilder<T> retryOn<E extends Exception>()
```

#### retryOnAny
设置多种重试异常类型。

```dart
RetryBuilder<T> retryOnAny(List<Type> exceptionTypes)
```

#### retryOnHttpStatus
设置HTTP状态码重试条件。

```dart
RetryBuilder<T> retryOnHttpStatus(List<int> statusCodes)
```

#### timeout
设置超时时间。

```dart
RetryBuilder<T> timeout(Duration timeout)
```

#### onRetry
设置重试回调。

```dart
RetryBuilder<T> onRetry(RetryCallback callback)
```

#### execute
执行操作。

```dart
Future<T> execute(Future<T> Function() operation)
```

## 重试策略

### FixedDelayPolicy
固定延迟策略。

```dart
class FixedDelayPolicy implements RetryPolicy {
  const FixedDelayPolicy({
    required this.delay,
  });
  
  final Duration delay;
}
```

### ExponentialBackoffPolicy
指数退避策略。

```dart
class ExponentialBackoffPolicy implements RetryPolicy {
  const ExponentialBackoffPolicy({
    this.initialDelay = const Duration(seconds: 1),
    this.multiplier = 2.0,
    this.maxDelay,
  });
  
  final Duration initialDelay;
  final double multiplier;
  final Duration? maxDelay;
}
```

### LinearBackoffPolicy
线性增长策略。

```dart
class LinearBackoffPolicy implements RetryPolicy {
  const LinearBackoffPolicy({
    this.initialDelay = const Duration(seconds: 1),
    this.increment = const Duration(seconds: 1),
    this.maxDelay,
  });
  
  final Duration initialDelay;
  final Duration increment;
  final Duration? maxDelay;
}
```

## 重试条件

### ExceptionCondition
异常条件。

```dart
class ExceptionCondition<T extends Exception> implements RetryCondition {
  const ExceptionCondition();
  
  factory ExceptionCondition.anyOf(List<Type> exceptionTypes) {
    return AnyExceptionCondition(exceptionTypes);
  }
}
```

### HttpStatusCondition
HTTP状态码条件。

```dart
class HttpStatusCondition implements RetryCondition {
  const HttpStatusCondition(this.statusCodes);
  
  factory HttpStatusCondition.range(int start, int end) {
    return HttpStatusCondition(
      List.generate(end - start + 1, (i) => start + i),
    );
  }
  
  final List<int> statusCodes;
}
```

## 回调类型

### RetryCallback
重试回调函数类型。

```dart
typedef RetryCallback = void Function(
  int attempt,
  Exception exception,
  Duration delay,
);
```

## 异常类

### RetryExhaustedException
重试次数耗尽异常。

```dart
class RetryExhaustedException implements Exception {
  const RetryExhaustedException({
    required this.attempts,
    required this.lastException,
  });
  
  final int attempts;
  final Exception lastException;
}
```

### RetryTimeoutException
重试超时异常。

```dart
class RetryTimeoutException implements Exception {
  const RetryTimeoutException({
    required this.timeout,
  });
  
  final Duration timeout;
}
```

### RetryConfigurationException
重试配置异常。

```dart
class RetryConfigurationException implements Exception {
  const RetryConfigurationException(this.message);
  
  final String message;
}
```

## 使用示例

### 基础用法

```dart
// 简单重试
final result = await FxRetry.execute(
  () async => await apiCall(),
  maxAttempts: 3,
);

// 带策略重试
final result = await FxRetry.execute(
  () async => await apiCall(),
  maxAttempts: 5,
  policy: ExponentialBackoffPolicy(
    initialDelay: Duration(seconds: 1),
    multiplier: 2.0,
  ),
);
```

### 构建器模式

```dart
final result = await FxRetry.builder<String>()
  .maxAttempts(3)
  .exponentialBackoff(initialDelay: Duration(seconds: 1))
  .retryOn<SocketException>()
  .timeout(Duration(seconds: 30))
  .onRetry((attempt, error, delay) {
    print('重试第 $attempt 次');
  })
  .execute(() async => await apiCall());
```

### 错误处理

```dart
try {
  final result = await FxRetry.execute(operation);
} on RetryExhaustedException catch (e) {
  print('重试失败: ${e.lastException}');
} on RetryTimeoutException catch (e) {
  print('操作超时: ${e.timeout}');
}
```