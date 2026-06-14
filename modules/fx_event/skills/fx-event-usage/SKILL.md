---
name: "fx-event-usage"
description: "使用 fx_event 进行类型化事件通信。适用于回调层级过深、跨模块通信、远距离组件交互、异步请求-响应等场景。"
metadata:
  author: toly
  version: "0.0.1"
  tags: [fx, event, bus, emitter, async, flutter]
---

# fx_event 使用指南

## 适用版本

fx_event: 0.0.1

## 环境检测

检查项目是否包含 fx_event 依赖。
- 没有 → 添加依赖
- 有但版本不同 → 提示用户升级技能或保持版本一致

---

## 适用场景

| 场景 | 问题 | fx_event 解法 |
|------|------|---------------|
| 回调层级过深 | Widget 嵌套 5+ 层传回调，中间层被迫透传 | 深层直接 `emit()`，顶层 `on<E>()` 接收 |
| 跨模块通信 | A 模块需要通知 B 模块，但两者无直接依赖 | 双方只依赖 fx_event，通过事件类型解耦 |
| 距离很远的交互 | 底部 Tab 点击需要刷新另一个 Tab 的列表 | 发送 `RefreshEvent`，目标页 mixin 监听 |
| 请求-响应 | 业务层需要 UI 确认（弹窗/选择器）再继续 | `AsyncFxEvent` 发送等待，UI 层 `complete` |

---

## 核心概念

| 概念 | 说明 |
|------|------|
| FxEvent | 事件基类，所有自定义事件继承它 |
| AsyncFxEvent\<T\> | 异步事件，发送方可等待处理结果 |
| FxEmitter | 全局事件总线单例 |
| FxEmitterMixin | 监听所有事件的 State mixin |
| FxSingleEventMixin | 只监听指定类型事件的 State mixin |

---

## 使用流程

```
1. 定义事件类     → 继承 FxEvent 或 AsyncFxEvent<T>
2. 注册监听       → FxEmitter().on<E>() 或 State mixin
3. 发送事件       → event.emit() 或 emitAsync()
4. 处理结果       → 异步事件通过 complete 返回
```

---

## 1. 定义事件

继承 `FxEvent` 定义同步事件，继承 `AsyncFxEvent<T>` 定义异步事件。

#[[file:references/define_event.md]]

---

## 2. 发送与监听

通过 `FxEmitter().on<E>()` 按类型监听，通过 `event.emit()` 发送。

#[[file:references/emit_listen.md]]

---

## 3. 异步事件

发送方 `emitAsync()` 等待，处理方 `complete(result)` 返回结果。

#[[file:references/async_event.md]]

---

## 4. State Mixin

在 StatefulWidget 中使用 mixin 自动管理订阅生命周期。

#[[file:references/state_mixin.md]]

---

## API 速查

| API | 作用 |
|-----|------|
| `event.emit()` | 发送事件到总线 |
| `FxEmitter().on<E>(handler)` | 按类型监听 |
| `FxEmitter().stream` | 监听所有事件 |
| `asyncEvent.emitAsync()` | 发送并等待结果 |
| `asyncEvent.emitAsync(timeout: ...)` | 带超时的异步发送 |
| `asyncEvent.complete(result)` | 处理方完成事件 |
| `asyncEvent.completeError(error)` | 处理方以错误完成 |
| `stream.whereType<S>()` | Stream 类型过滤扩展 |

---

## 生成指导

1. 事件类用 `const` 构造（如果字段都是 final）
2. AsyncFxEvent 每次使用都创建新实例，不可复用
3. 显式声明所有类型（strict-raw-types）
4. State mixin 中不需要手动 cancel，dispose 自动处理
5. 异步事件如果不确定是否有 handler，建议带 timeout
6. 事件类命名用 `XxxEvent` 后缀
