# fx_trace

应用级异常/日志追踪分发，基于 fx_exception 协议层。

## 安装

```yaml
dependencies:
  fx_trace: ^0.1.0
```

## 快速开始

```dart
import 'package:fx_trace/fx_trace.dart';

// 监听所有 Trace
FxTrace().addTraceListener((Trace trace) {
  print('[${trace.code.value}] ${trace.message}');
});

// 发送日志
LogTrace('用户登录成功', level: LogLevel.info).emit();

// 发送提示
TipTrace.warning('网络不稳定', 1001).emit();

// 捕获异常
try {
  // ...
} catch (e, s) {
  CatchTrace(e, s, msg: '解析失败').emit();
}
```

## 特性

- **统一 Trace 协议** — 基于 fx_exception，与 fx_dio 类型互通
- **全局单例分发** — `FxTrace()` 一处监听，全局收集
- **日志级别过滤** — `FxTrace.minLogLevel` 控制输出阈值
- **预置 Trace 类型** — LogTrace / TipTrace / CatchTrace 开箱即用
- **State 生命周期绑定** — `TraceStateMixin` 自动注册/注销

## 日志级别

```dart
FxTrace.minLogLevel = LogLevel.warning; // 只接收 warning 及以上
```

| 级别 | 说明 |
|------|------|
| none | 全部过滤 |
| info | 信息 |
| debug | 调试 |
| warning | 警告 |
| error | 错误 |

## 与 fx_dio 配合

```dart
// fx_dio 的异常桥接到 FxTrace 全局监听
FxDio().addTraceListener((Trace trace) => FxTrace().emit(trace));
```

桥接后，网络异常和应用日志统一进入 `FxTrace` 的 listener。

## TraceStateMixin

```dart
class _MyPageState extends State<MyPage> with TraceStateMixin {
  @override
  void onTrace(Trace trace) {
    if (trace is TipTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trace.message)),
      );
    }
  }
}
```

## 依赖

| 包 | 说明 |
|----|------|
| [fx_exception](https://pub.dev/packages/fx_exception) | Trace/Code 协议定义 |
