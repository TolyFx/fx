/// 验证 Toast 能力契约可以由宿主完整实现。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_ability/fx_ability.dart';

void main() {
  test('宿主可以实现 Toast 能力契约', () {
    final _RecordingToast toast = _RecordingToast();

    FxAbility().registerToast(toast);
    FxAbility().toast.success('保存成功');

    expect(FxAbility().isToastRegistered, isTrue);
    expect(toast.message, '保存成功');
    expect(toast.backgroundColor, toast.colorSchema[ToastType.success]);
  });
}

/// 用于验证能力契约的宿主测试实现。
class _RecordingToast extends Toastable {
  /// 最近一次提示文本。
  String? message;

  /// 最近一次提示背景色。
  Color? backgroundColor;

  @override
  void show(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    ToastAction? action,
  }) {
    this.message = message;
    this.backgroundColor = backgroundColor;
  }
}
