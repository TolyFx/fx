```dart
import 'dart:async';
import 'package:fx_event/fx_event.dart';

// --- 监听 ---

// 按类型监听
final StreamSubscription<UserLogoutEvent> sub =
    FxEmitter().on<UserLogoutEvent>((UserLogoutEvent event) {
  print('用户登出: ${event.reason}');
});

// 监听所有事件
final StreamSubscription<FxEvent> allSub =
    FxEmitter().stream.listen((FxEvent event) {
  print('收到事件: $event');
});

// --- 发送 ---

// 便捷发送
const RefreshListEvent().emit();

// 通过 FxEmitter 发送
FxEmitter().emit(const UserLogoutEvent('token expired'));

// --- 取消 ---
sub.cancel();
allSub.cancel();
```
