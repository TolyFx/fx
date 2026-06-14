/// Fx 框架统一集成入口。
///
/// 引入此包即获得全部核心能力：
/// - 异常协议（fx_exception）
/// - 环境检测（fx_env）
/// - 事件总线（fx_event）
/// - 追踪分发（fx_trace）
/// - HTTP 客户端（fx_dio）
/// - 启动管理（fx_boot_starter）
library fx_framework;

export 'package:fx_exception/fx_exception.dart';
export 'package:fx_env/fx_env.dart';
export 'package:fx_event/fx_event.dart';
export 'package:fx_trace/fx_trace.dart';
export 'package:fx_dio/fx_dio.dart';
export 'package:fx_boot_starter/fx_boot_starter.dart';
