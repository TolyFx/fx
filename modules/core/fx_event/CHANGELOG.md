# Changelog

## Unreleased

- Added: `FxEmitter.scoped()` 独立事件域与可选同步分发
- Added: `eventsOf<E>()` 类型化事件流
- Added: `FxEventSource<E>` 跨模块只读事件来源契约
- Added: 作用域事件域生命周期管理，同时保持全局事件总线兼容

## 0.0.1

- Added: FxEvent 基类 + FxEmitter 全局事件总线
- Added: AsyncFxEvent 异步请求-响应模式
- Added: FxEmitterMixin / FxSingleEventMixin State 生命周期绑定
- Added: WhereTypeStream 扩展（零依赖，对标 stream_transform）
- Added: AI Skill (fx-event-usage)
