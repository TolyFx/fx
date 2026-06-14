```dart
import 'package:flutter/material.dart';
import 'package:fx_trace/fx_trace.dart';

// --- 全局监听 ---

void initTraceListener() {
  FxTrace().addTraceListener((Trace trace) {
    if (trace is TipTrace) {
      // 显示 SnackBar
    }
    if (trace is CatchTrace) {
      // 上报错误监控
    }
  });
}

// --- TraceStateMixin ---

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TraceStateMixin<AppShell> {
  @override
  void onTrace(Trace trace) {
    if (trace is TipTrace && trace.level == TipLevel.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trace.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}
```
