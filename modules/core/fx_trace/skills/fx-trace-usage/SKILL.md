---
name: "fx-trace-usage"
description: "使用 fx_trace 进行应用级异常/日志追踪。统一收集网络异常、业务提示、调试日志，支持级别过滤和 State 生命周期绑定。"
metadata:
  author: toly
  version: "0.1.0"
  tags: [fx, trace, log, exception, error, flutter]
---

# fx_trace 使用指南

## 适用版本

fx_trace: 0.1.0 | fx_exception: 0.0.1+2

## 环境检测

检查项目是否包含 fx_trace 依赖。
- 没有 → 添加依赖
- 有但版本不同 → 提示用户升级技能或保持版本一致

---

## 核心概念

| 概念 | 说明 |
|------|------|
| Trace | 异常/日志协议 mixin（来自 fx_exception） |
| FxTrace | 全局追踪分发单例 |
| LogTrace | 日志追踪，支持级别过滤 |
| TipTrace | 提示追踪（info/warning/error/success） |
| CatchTrace | 捕获的异常包装 |
| TraceStateMixin | 在 State 中自动监听 Trace |

---

## 使用流程

```
1. 注册监听   → FxTrace().addTraceListener(...)
2. 发送 Trace → trace.emit()
3. 设置级别   → FxTrace.minLogLevel = LogLevel.xxx
4. 桥接 fx_dio（可选） → 网络异常统一收集
```

---

## 1. 监听

注册全局 listener 或使用 State mixin。

#[[file:references/listen.md]]

---

## 2. 发送 Trace

使用 LogTrace / TipTrace / CatchTrace 或自定义 Trace。

#[[file:references/emit_trace.md]]

---

## 3. 日志级别

通过 minLogLevel 控制 LogTrace 的过滤阈值。

#[[file:references/log_level.md]]

---

## 4. 与 fx_dio 桥接

将 fx_dio 的网络异常统一收入 FxTrace。

#[[file:references/bridge_dio.md]]

---

## API 速查

| API | 作用 |
|-----|------|
| `FxTrace().addTraceListener(callback)` | 注册监听 |
| `FxTrace().removeTraceListener(callback)` | 移除监听 |
| `FxTrace().emit(trace)` | 手动发送 |
| `trace.emit()` | 便捷发送（扩展方法） |
| `FxTrace.minLogLevel` | 全局日志级别阈值 |
| `LogTrace(msg, level: ...)` | 日志 |
| `TipTrace(msg, code)` | 提示 |
| `TipTrace.warning(msg, code)` | 警告提示 |
| `CatchTrace(error, stack)` | 捕获异常 |

---

## 生成指导

1. 所有自定义 Trace 实现 fx_exception 的 `Trace` mixin
2. 显式声明所有类型
3. TraceStateMixin 中不需要手动 removeListener
4. LogTrace 的 code 默认 0，不需要时无需传
5. 与 fx_dio 桥接只需一行代码
