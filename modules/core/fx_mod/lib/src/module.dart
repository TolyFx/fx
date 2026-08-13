import 'dart:async';

import 'context.dart';
import 'contribution.dart';

/// 模块运行时事件的语义标记。
abstract interface class FxModEvent {
  const FxModEvent();
}

/// 可由宿主统一装配的独立功能模块。
abstract class FxModule {
  const FxModule();

  /// 模块在当前应用中的唯一标识。
  String get id;

  /// 必须先于当前模块启动的模块标识。
  Set<String> get dependencies => const <String>{};

  /// 模块向上层框架声明的静态能力。
  Iterable<FxModContribution> get contributions => const <FxModContribution>[];

  /// 执行无需其他模块已启动的准备工作。
  FutureOr<void> onPrepare(FxModContext context) {}

  /// 在所有依赖模块完成启动后激活当前模块。
  FutureOr<void> onStart(FxModContext context) {}

  /// 接收宿主广播的运行时事件。
  FutureOr<void> onEvent(FxModContext context, FxModEvent event) {}

  /// 释放模块持有的资源。
  FutureOr<void> onDispose(FxModContext context) {}
}
