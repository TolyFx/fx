```dart
import 'package:fx_event/fx_event.dart';

// --- 定义 ---

class ConfirmPayEvent extends AsyncFxEvent<bool> {
  final double amount;
  ConfirmPayEvent(this.amount);
}

// --- 处理方（通常在 UI 层注册）---

FxEmitter().on<ConfirmPayEvent>((ConfirmPayEvent event) async {
  // 弹窗让用户确认
  final bool confirmed = await showConfirmDialog('支付 ${event.amount} 元？');
  event.complete(confirmed);
});

// --- 发送方（业务逻辑层）---

Future<void> handlePay(double amount) async {
  final bool ok = await ConfirmPayEvent(amount).emitAsync();
  if (ok) {
    // 执行支付
  }
}

// --- 带超时 ---

Future<void> handlePayWithTimeout(double amount) async {
  try {
    final bool ok = await ConfirmPayEvent(amount).emitAsync(
      timeout: const Duration(seconds: 30),
    );
    if (ok) { /* 支付 */ }
  } on TimeoutException {
    // 超时处理
  }
}

// --- 错误完成 ---

FxEmitter().on<ConfirmPayEvent>((ConfirmPayEvent event) {
  event.completeError(Exception('支付通道不可用'));
});
```
