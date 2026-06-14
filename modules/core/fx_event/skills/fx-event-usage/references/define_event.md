```dart
import 'package:fx_event/fx_event.dart';

/// 同步事件 — 普通通知，fire-and-forget
class RefreshListEvent extends FxEvent {
  const RefreshListEvent();
}

class UserLogoutEvent extends FxEvent {
  final String reason;
  const UserLogoutEvent(this.reason);
}

/// 异步事件 — 发送方等待处理结果
class ConfirmDeleteEvent extends AsyncFxEvent<bool> {
  final String itemId;
  ConfirmDeleteEvent(this.itemId);
}

class PickFileEvent extends AsyncFxEvent<String?> {}
```
