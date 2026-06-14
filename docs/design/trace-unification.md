# fx_exception 与 fx_trace 统一方案

> 日期: 2026-06-14

---

## 背景

fx 框架中存在两个"追踪"相关包，API 几乎相同但不兼容，用户无法同时 import。

---

## 现状对比

| 维度 | fx_exception (0.0.1+2) | fx_trace (0.0.6) |
|------|------------------------|------------------|
| Code | `mixin Code { int get code; }` | `mixin Code { int? get value; }` |
| Trace | `mixin Trace { Code get code; ... }` | `mixin Trace implements Exception { Code? get code; ... }` |
| TraceMixin | 纯遍历通知 | + 日志级别过滤 + try-catch 保护 |
| 单例入口 | 无（FxDio 自己 with TraceMixin） | `FxTrace()` 全局单例 |
| 预置实现 | `RequestException` + `RequestErrorCode` | `LogTrace` / `TipTrace` / `CatchTrace` |
| 事件总线 | 无 | `FxEmitter` / `FxEvent` / `AsyncFxEvent` |
| State mixin | 无 | `TraceStateMixin` / `FxEmitterMixin` / `FxSingleEventMixin` |
| 字段名 | `Code.code` (non-null) | `Code.value` (nullable) |
| 依赖方 | fx_dio | 应用层直接使用 |

---

## 核心矛盾

1. **同名冲突** — 两包都 export `Trace`、`TraceMixin`、`Code`，无法同时 import
2. **类型不互通** — fx_dio 的 `RequestException` 实现的是 fx_exception 的 Trace，无法直接被 fx_trace 的 `FxTrace()` 监听
3. **字段不一致** — `code` vs `value`，nullable 规则不同
4. **功能重复** — TraceMixin 的 listener 管理逻辑完全重复

---

## 统一方案

### 核心原则

**fx_exception 零改动**。fx_trace 适配 fx_exception 的现有接口。

### 定位划分

| 包 | 定位 | 改动 |
|----|------|------|
| fx_exception | **协议层** — Trace/Code/TraceMixin 类型定义 + RequestException | 无改动 |
| fx_dio | **网络层** — 依赖 fx_exception | 无改动 |
| fx_trace | **应用层** — 全局追踪单例 + 预置 Trace 实现 + 事件总线 | breaking change |

### 依赖关系

```
fx_exception（协议层，不动）
     ↑              ↑
     │              │
  fx_dio         fx_trace（应用层，适配 fx_exception 接口）
```

---

## fx_trace 改动详情

### 删除（去重复）

| 删除文件 | 原因 |
|----------|------|
| `lib/src/model/code/code.dart` | 用 fx_exception 的 Code |
| `lib/src/model/code/http.dart` | HttpCode 保留但改为实现 fx_exception 的 Code |
| `lib/src/model/model.dart` | barrel 不再需要 |

### 修改

| 文件 | 改动 |
|------|------|
| pubspec.yaml | 新增 `fx_exception: ^0.0.1+2` |
| trace.dart | `Trace` mixin 改为 re-export fx_exception 的 Trace，删除自定义 |
| mixin.dart | `TraceMixin` 改为 re-export fx_exception 的 TraceMixin；`FxTrace` override `notifyTrace` 加日志级别过滤 + try-catch |
| catch_trace.dart | `with Code, Trace` → 实现 fx_exception 的接口，`value` → `code` |
| log_trace.dart | 同上，`value` 默认 0（日志无 code 语义，给默认值） |
| tip_trace.dart | 同上 |
| http.dart | `HttpCode with Code` → 实现 fx_exception 的 Code，`value` → `code` |
| fx_trace.dart (barrel) | re-export `package:fx_exception/fx_exception.dart` |

### 关键适配点

fx_exception 的 `Code.code` 是 `int`（non-null），fx_trace 原来的 `Code.value` 是 `int?`。

适配方式：所有 Trace 实现的 `code` 字段给默认值：

```dart
// LogTrace — 日志不需要 code，默认 0
class LogTrace with Trace {
  @override
  Code get code => _LogCode(0);
  // ...
}

// CatchTrace — 捕获异常可能有 code
class CatchTrace with Trace {
  @override
  Code get code => _CatchCode(value ?? 0);
  // ...
}
```

或更简洁：让各 Trace 类自身 `with Code, Trace`（和 fx_exception 的 RequestException 模式一致）：

```dart
class LogTrace with Code, Trace {
  @override
  final int code;  // 默认 0

  @override
  final String? message;
  // ...
}
```

---

## 统一后的用户体验

### 只用 fx_dio（不变）

```dart
import 'package:fx_dio/fx_dio.dart';

FxDio().addTraceListener((Trace trace) {
  print(trace.message);
});
```

### 同时用 fx_dio + fx_trace

```dart
import 'package:fx_trace/fx_trace.dart';
// fx_trace re-export 了 fx_exception，类型统一

// 所有 Trace 类型统一，可互相识别
FxTrace().addTraceListener((Trace trace) {
  if (trace is RequestException) { /* 网络异常 */ }
  if (trace is TipTrace) { /* 提示 */ }
  if (trace is LogTrace) { /* 日志 */ }
});

// 桥接：fx_dio 的异常流入 FxTrace 全局
FxDio().addTraceListener((Trace trace) => FxTrace().emit(trace));
```

### 事件总线（独立使用，不受影响）

```dart
import 'package:fx_trace/fx_trace.dart';

class LoginEvent extends FxEvent { ... }
FxEmitter().on<LoginEvent>((e) => ...);
LoginEvent().emit();
```

---

## 执行顺序

1. **fx_exception** — 不动，不发布
2. **fx_dio** — 不动，不发布
3. **fx_trace → 0.1.0** — 依赖 fx_exception，删除重复定义，适配接口，发布

---

## 风险评估

| 风险 | 影响 | 缓解 |
|------|------|------|
| fx_trace breaking change | 已使用 fx_trace 的应用需适配 | 0.0.x 阶段用户量小，版本号升到 0.1.0 明确标记 |
| LogTrace 强制 non-null code | 语义上日志不一定有 code | 默认值 0 即可，不影响使用 |
| HttpCode 归属 | 原在 fx_trace 的 model 里 | 保留在 fx_trace，改为实现 fx_exception 的 Code |

---

## 预期收益

- fx_exception 和 fx_dio **零影响**
- 用户不再困惑"用哪个 Trace"
- fx_dio 的异常可无缝流入 fx_trace 的全局监听
- 类型统一后，跨模块的 Trace 可互相识别
- fx_trace 减少 ~30 行重复代码
