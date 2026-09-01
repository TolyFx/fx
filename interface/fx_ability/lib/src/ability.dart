/// 提供宿主能力的全局注册与访问入口。
library;

import 'toast_ability.dart';

/// FrameworkX 客户端的宿主能力注册与访问入口。
class FxAbility {
  FxAbility._();

  /// 全局 Ability 单例。
  static final FxAbility _instance = FxAbility._();

  /// 获取全局 Ability 单例。
  factory FxAbility() => _instance;

  /// 当前宿主注册的 Toast 实现。
  Toastable? _toast;

  /// 当前是否已经注册 Toast 能力。
  bool get isToastRegistered => _toast != null;

  /// 注册或替换宿主 Toast 实现。
  void registerToast(Toastable toast) {
    _toast = toast;
  }

  /// 获取宿主 Toast 实现。
  Toastable get toast {
    final Toastable? result = _toast;
    if (result == null) {
      throw StateError('Toast 尚未注册，请先调用 registerToast。');
    }
    return result;
  }
}
