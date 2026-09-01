/// 定义 Toast 能力契约及其默认便捷行为，不包含宿主 UI 实现。
library;

import 'package:flutter/material.dart';

/// Toast 提示类型。
enum ToastType { success, error, warning, info }

/// Toast 中可选的操作按钮。
class ToastAction {
  /// 操作按钮文字。
  final String label;

  /// 点击操作按钮时执行的回调。
  final VoidCallback onPressed;

  /// 操作按钮文字颜色。
  final Color? textColor;

  const ToastAction({
    required this.label,
    required this.onPressed,
    this.textColor,
  });
}

/// 由宿主应用实现的全局 Toast 能力。
abstract class Toastable {
  /// 不同提示类型对应的默认背景色。
  Map<ToastType, Color> get colorSchema => {
        ToastType.success: const Color(0xFF2C2C2E),
        ToastType.error: const Color(0xFFB33A3A),
        ToastType.warning: const Color(0xFF9A6700),
        ToastType.info: const Color(0xFF2C2C2E),
      };

  /// 显示 Toast 消息。
  void show(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    ToastAction? action,
  });

  /// 显示成功提示。
  void success(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(
      message,
      duration: duration,
      backgroundColor: colorSchema[ToastType.success],
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  /// 显示错误提示。
  void error(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(
      message,
      duration: duration,
      backgroundColor: colorSchema[ToastType.error],
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  /// 显示警告提示。
  void warning(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(
      message,
      duration: duration,
      backgroundColor: colorSchema[ToastType.warning],
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  /// 显示普通信息。
  void info(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(
      message,
      duration: duration,
      backgroundColor: colorSchema[ToastType.info],
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}

/// 兼容 fx 早期版本中的 Toast 能力命名。
typedef ToastAbility = Toastable;
