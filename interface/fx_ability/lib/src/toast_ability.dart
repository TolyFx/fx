import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Toast 能力抽象接口
abstract class ToastAbility {
  /// 显示 Toast 消息
  void show(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  });

  /// 成功提示
  void success(String message, {Duration? duration});

  /// 错误提示
  void error(String message, {Duration? duration});

  /// 警告提示
  void warning(String message, {Duration? duration});

  /// 信息提示
  void info(String message, {Duration? duration});
}
