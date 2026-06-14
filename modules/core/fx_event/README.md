# fx_event

轻量级类型化事件总线，零第三方依赖。支持同步/异步事件和 State 生命周期绑定。

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
- **零依赖** — 不依赖任何第三方包
- **异步事件** — AsyncFxEvent 支持请求-响应模式
- **生命周期绑定** — FxEmitterMixin / FxSingleEventMixin 自动 dispose
- **高性能** — 单层 controller，延迟订阅，无中间 stream 开销
- **Stream 扩展** — 导出 `WhereTypeStream`，任何 Stream 可用 `.whereType<T>()`

## API

| API | 说明 |
|-----|------|
| `FxEmitter().emit(event)` | 发送事件 |
| `FxEmitter().on<E>(handler)` | 按类型监听 |
| `FxEmitter().stream` | 所有事件的原始流 |
| `event.emit()` | 便捷发送 |
| `asyncEvent.emitAsync()` | 发送并等待结果 |
| `asyncEvent.complete(result)` | 处理方完成事件 |
| `stream.whereType<S>()` | Stream 类型过滤扩展 |
