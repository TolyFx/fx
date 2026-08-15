# fx_event

轻量级类型化事件流，零第三方依赖。支持全局事件总线、独立作用域、同步/异步事件和 State 生命周期绑定。

## 安装

```yaml
dependencies:
  fx_event: ^0.0.1
```

## 快速开始

```dart
import 'package:fx_event/fx_event.dart';

// 定义事件
class LoginEvent extends FxEvent {
  final String userId;
  const LoginEvent(this.userId);
}

// 监听
FxEmitter().on<LoginEvent>((event) => print('登录: ${event.userId}'));

// 发送
const LoginEvent('user_1').emit();
```

## 作用域事件流

框架或业务组件需要隔离事件边界时，可以创建并自行持有作用域 emitter：

```dart
class RouteEvent extends FxEvent {
  const RouteEvent();
}

final FxEmitter emitter = FxEmitter.scoped(sync: true);

final StreamSubscription<RouteEvent> subscription =
    emitter.on<RouteEvent>((RouteEvent event) {
  // 只接收当前作用域内的路由事件。
});

emitter.emit(RouteEvent());

await subscription.cancel();
await emitter.dispose();
```

`FxEmitter()`、`FxEmitter.global` 和 `event.emit()` 始终使用全局事件总线，保持原有行为。作用域事件必须通过对应的 `emitter.emit(event)` 发送，并由持有者负责释放。

跨模块共享时只暴露 `FxEventSource<E>` 或其中的 `events`，不要暴露 emitter：

```dart
abstract final class RouteEvents implements FxEventSource<RouteEvent> {
  // 实现方持有并维护自己的 FxEmitter.scoped()。
}
```

这样消费模块只能订阅，不能向其他模块的事件域发送事件或释放事件域。

## 异步事件

发送方可以等待处理方返回结果：

```dart
class PickColorEvent extends AsyncFxEvent<Color> {}

// 处理方
FxEmitter().on<PickColorEvent>((event) async {
  final color = await showColorPicker();
  event.complete(color);
});

// 发送方
final color = await PickColorEvent().emitAsync();
```

支持超时保护：

```dart
final result = await event.emitAsync(timeout: const Duration(seconds: 10));
```

## State Mixin

自动管理订阅生命周期：

```dart
// 监听所有事件
class _MyState extends State<MyPage> with FxEmitterMixin {
  @override
  void onEvent(FxEvent event) { ... }
}

// 只监听特定类型
class _DetailState extends State<Detail>
    with FxSingleEventMixin<Detail, PriceUpdateEvent> {
  @override
  void onEvent(PriceUpdateEvent event) { ... }
}
```

## 特性

- **类型安全** — 泛型过滤，编译期检查事件类型
- **边界隔离** — `FxEmitter.scoped()` 可创建互不干扰的事件域
- **零依赖** — 不依赖任何第三方包
- **异步事件** — AsyncFxEvent 支持请求-响应模式
- **生命周期绑定** — FxEmitterMixin / FxSingleEventMixin 自动 dispose
- **高性能** — 单层 controller，延迟订阅，无中间 stream 开销
- **Stream 扩展** — 导出 `WhereTypeStream`，任何 Stream 可用 `.whereType<T>()`

## API

| API | 说明 |
|-----|------|
| `FxEmitter().emit(event)` | 发送全局事件 |
| `FxEmitter.global` | 获取全局事件总线 |
| `FxEmitter.scoped()` | 创建独立事件域，可选择同步分发 |
| `FxEmitter().on<E>(handler)` | 按类型监听 |
| `emitter.eventsOf<E>()` | 获取指定类型的事件流 |
| `FxEventSource<E>` | 跨模块只读事件来源契约 |
| `FxEmitter().stream` | 所有事件的原始流 |
| `emitter.dispose()` | 释放作用域事件域；全局事件总线不可释放 |
| `event.emit()` | 便捷发送 |
| `asyncEvent.emitAsync()` | 发送并等待结果 |
| `asyncEvent.complete(result)` | 处理方完成事件 |
| `stream.whereType<S>()` | Stream 类型过滤扩展 |
