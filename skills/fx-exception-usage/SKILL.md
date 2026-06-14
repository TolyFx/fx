---
name: "fx-exception-usage"
description: "使用 fx_exception 构建统一异常追踪体系。提供 Code、Trace、TraceMixin 三个核心协议，各模块基于此扩展自定义异常。"
metadata:
  author: toly
  version: "0.0.1+1"
  tags: [fx, exception, trace, error, flutter]
---

# fx_exception 使用指南

## 适用版本

fx_exception: 0.0.1+2

## 环境检测

检查项目是否包含 fx_exception 依赖。
- 没有 → 添加依赖
- 有但版本不同 → 提示用户升级技能或保持版本一致

---

## 核心协议

| 协议 | 职责 |
|------|------|
| `Code` mixin | 错误码标准，任何 enum with Code 即可接入 |
| `Trace` mixin | 异常信息标准：code + message + error + stack |
| `TraceMixin` | 异常分发，支持多监听器，addTraceListener / removeTraceListener / dispose |

---

## 使用流程

```
1. 定义错误码    → enum XxxCode with Code { ... }
2. 定义异常类    → class XxxException with Trace implements Exception { ... }
3. 混入 TraceMixin → 需要分发异常的类 with TraceMixin
4. 监听          → addTraceListener 注册回调
```

---

## 1. 自定义错误码

#[[file:references/custom_code.md]]

---

## 2. 自定义异常

#[[file:references/custom_trace.md]]

---

## 3. TraceMixin 使用

#[[file:references/trace_mixin.md]]

---

## 内置成员

| 成员 | 说明 |
|------|------|
| `RequestErrorCode` | 框架级错误码：convert(0)、emptyData(1)、exception(2) |
| `RequestException` | 框架级请求异常，fx_dio 内部使用 |
| `kDefaultErrorHandler` | 默认 debug 日志输出（debugPrint） |
| `ExceptionCallback` | `void Function(Trace trace)` 类型别名 |

---

## 设计原则

- 框架只定义协议（Code / Trace），不定义业务语义
- 用户通过 enum + class 自由扩展，编译期类型安全
- TraceMixin 可被任意类混入，不限于网络层
- 所有自定义异常自动兼容 TraceMixin 分发链路

---

## 生成指导

1. 错误码命名用业务语义，不要用 error1/error2
2. 自定义异常类建议加便捷判断属性（如 `isTokenExpired`）
3. 显式声明所有类型
4. 监听器中根据 `trace.error` 的 runtimeType 做分流
