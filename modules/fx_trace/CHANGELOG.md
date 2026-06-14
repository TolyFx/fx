## 0.1.0

- Breaking: 统一 Trace/Code/TraceMixin 为 fx_exception 协议，删除自身重复定义
- Breaking: 事件总线拆分为独立包 fx_event
- Changed: 移除 stream_transform 依赖
- Changed: 移除 HttpCode（不属于追踪职责）
- Added: TraceEmitExt 扩展，任何 Trace 可 `.emit()`
- Added: AI Skill (fx-trace-usage)
- Added: README 完整使用文档

## 0.0.6
add [AsyncFxEvent]

## 0.0.5
* 0.0.5+6: add [Trace#toString]
* 0.0.5+5: add [TraceStateMixin]/[TraceStateMixin.minLogLevel]
* 0.0.5+1: add [StackTrace] for default Trace
* add [FxSingleEventMixin]/[FxEmitter#on]

## 0.0.4

* add [Trace#emit]/[LogTrace]


## 0.0.3

* add [FxEvent]/[FxEmitter]/[FxEmitterMixin]


## 0.0.2

* add [TipLevel] in TipTrace
* download dart sdk version: min 3.4.0

## 0.0.1

* add [FxTrace]/[CatchTrace]/[TipTrace]
* add [Code]/[HttpCode]




