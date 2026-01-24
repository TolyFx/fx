import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}


abstract class Toastable {


  Map<ToastType, Color> get colorSchema => {
    ToastType.success: Color(0xFF52C41A),
    ToastType.error: Color(0xFFFF4D4F),
    ToastType.warning: Color(0xFFFAAD14),
    ToastType.info: Color(0xFF000000),
  };

  /// 显示 Toast 消息
  void show(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  });

  /// 成功提示
  void success(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(message, backgroundColor: colorSchema[ToastType.success], duration: duration, textColor: textColor, fontSize: fontSize);
  }

  /// 错误提示
  void error(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(message, backgroundColor: colorSchema[ToastType.error], duration: duration, textColor: textColor, fontSize: fontSize);
  }

  /// 警告提示
  void warning(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(message, backgroundColor: colorSchema[ToastType.warning], duration: duration, textColor: textColor, fontSize: fontSize);
  }

  /// 信息提示
  void info(
    String message, {
    Duration? duration,
    Color? textColor,
    double? fontSize,
  }) {
    show(message, backgroundColor: colorSchema[ToastType.info], duration: duration, textColor: textColor, fontSize: fontSize);
  }
}