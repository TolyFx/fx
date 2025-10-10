# Flutter 重试机制通用解决方案设计文档

## 概述

fx_retry 是一个为 Flutter 应用提供通用重试机制的包，支持网络请求、异步操作等场景的智能重试策略。

## 核心特性

- 🔄 **多种重试策略**: 固定延迟、指数退避、线性增长
- 🎯 **条件重试**: 基于异常类型、HTTP状态码的智能重试
- ⏱️ **超时控制**: 单次操作和总体超时限制
- 📊 **重试监控**: 详细的重试过程回调和统计
- 🛡️ **类型安全**: 完整的泛型支持
- 🎨 **易于使用**: 简洁的API设计

## 架构设计

### 核心组件

```
FxRetry (主入口)
├── RetryPolicy (重试策略)
│   ├── FixedDelayPolicy (固定延迟)
│   ├── ExponentialBackoffPolicy (指数退避)
│   └── LinearBackoffPolicy (线性增长)
├── RetryCondition (重试条件)
│   ├── ExceptionCondition (异常条件)
│   └── HttpStatusCondition (HTTP状态条件)
└── RetryCallback (重试回调)
```

### 重试策略

#### 1. 固定延迟策略 (FixedDelayPolicy)
```dart
// 每次重试间隔固定时间
FixedDelayPolicy(delay: Duration(seconds: 1))
```

#### 2. 指数退避策略 (ExponentialBackoffPolicy)
```dart
// 延迟时间指数增长: 1s, 2s, 4s, 8s...
ExponentialBackoffPolicy(
  initialDelay: Duration(seconds: 1),
  multiplier: 2.0,
  maxDelay: Duration(seconds: 30),
)
```

#### 3. 线性增长策略 (LinearBackoffPolicy)
```dart
// 延迟时间线性增长: 1s, 2s, 3s, 4s...
LinearBackoffPolicy(
  initialDelay: Duration(seconds: 1),
  increment: Duration(seconds: 1),
  maxDelay: Duration(seconds: 10),
)
```

### 重试条件

#### 1. 异常条件
```dart
// 仅在特定异常时重试
ExceptionCondition<SocketException>()

// 多种异常类型
ExceptionCondition.anyOf([
  SocketException,
  TimeoutException,
  HttpException,
])
```

#### 2. HTTP状态条件
```dart
// 特定状态码重试
HttpStatusCondition([500, 502, 503, 504])

// 状态码范围
HttpStatusCondition.range(500, 599) // 5xx错误
```

## API 设计

### 基础用法

```dart
// 简单重试
final result = await FxRetry.execute<String>(
  () async => await apiCall(),
  maxAttempts: 3,
);

// 带策略的重试
final result = await FxRetry.execute<String>(
  () async => await apiCall(),
  maxAttempts: 5,
  policy: ExponentialBackoffPolicy(
    initialDelay: Duration(seconds: 1),
    multiplier: 2.0,
  ),
);
```

### 高级用法

```dart
// 完整配置
final result = await FxRetry.execute<ApiResponse>(
  () async => await httpClient.get('/api/data'),
  maxAttempts: 3,
  policy: ExponentialBackoffPolicy(
    initialDelay: Duration(seconds: 1),
    multiplier: 1.5,
    maxDelay: Duration(seconds: 10),
  ),
  condition: ExceptionCondition.anyOf([
    SocketException,
    TimeoutException,
  ]),
  timeout: Duration(seconds: 30),
  onRetry: (attempt, exception, delay) {
    print('重试第 $attempt 次，延迟 ${delay.inSeconds}s');
  },
);
```

### 构建器模式

```dart
final result = await FxRetry.builder<String>()
  .maxAttempts(5)
  .exponentialBackoff(
    initialDelay: Duration(seconds: 1),
    multiplier: 2.0,
  )
  .retryOn<SocketException>()
  .timeout(Duration(seconds: 30))
  .onRetry((attempt, error, delay) {
    logger.warning('重试 $attempt: $error');
  })
  .execute(() async => await apiCall());
```

## 使用场景

### 1. 网络请求重试
```dart
// HTTP 请求重试
final response = await FxRetry.execute(
  () => http.get(Uri.parse('https://api.example.com/data')),
  maxAttempts: 3,
  policy: ExponentialBackoffPolicy(initialDelay: Duration(seconds: 1)),
  condition: HttpStatusCondition([500, 502, 503, 504]),
);
```

### 2. 数据库操作重试
```dart
// 数据库连接重试
final data = await FxRetry.execute(
  () => database.query('SELECT * FROM users'),
  maxAttempts: 3,
  condition: ExceptionCondition<DatabaseException>(),
);
```

### 3. 文件操作重试
```dart
// 文件读取重试
final content = await FxRetry.execute(
  () => File('data.json').readAsString(),
  maxAttempts: 3,
  condition: ExceptionCondition<FileSystemException>(),
);
```

## 错误处理

### 异常类型

- `RetryExhaustedException`: 重试次数耗尽
- `RetryTimeoutException`: 总体超时
- `RetryConfigurationException`: 配置错误

### 错误信息

```dart
try {
  final result = await FxRetry.execute(operation);
} on RetryExhaustedException catch (e) {
  print('重试失败: ${e.lastException}');
  print('尝试次数: ${e.attempts}');
} on RetryTimeoutException catch (e) {
  print('重试超时: ${e.timeout}');
}
```

## 性能考虑

- 最小内存占用，避免不必要的对象创建
- 异步操作优化，不阻塞主线程
- 可配置的超时机制防止资源泄露
- 支持取消操作的 CancellationToken

## 测试策略

- 单元测试覆盖所有重试策略
- 集成测试验证网络场景
- 性能测试确保低延迟
- 边界条件测试保证稳定性

## 扩展性

- 插件化的重试策略接口
- 自定义重试条件支持
- 可扩展的回调机制
- 支持第三方监控集成

## 最佳实践

1. **选择合适的重试策略**: 网络请求使用指数退避，数据库操作使用固定延迟
2. **设置合理的重试次数**: 通常3-5次足够，避免过度重试
3. **配置超时时间**: 防止长时间等待
4. **记录重试日志**: 便于问题排查和性能优化
5. **优雅降级**: 重试失败后提供备选方案

## 版本规划

- **v0.1.0**: 基础重试功能
- **v0.2.0**: 高级策略和条件
- **v0.3.0**: 监控和统计功能
- **v1.0.0**: 稳定版本发布