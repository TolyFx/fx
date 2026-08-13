/// 模块运行期间共享的类型化对象容器。
///
/// 容器由应用装配层持有。模块只应发布稳定能力，不应将页面等短生命周期
/// 对象注册到这里。
class FxModContext {
  /// 按类型保存的共享对象。
  final Map<Type, Object> _values = <Type, Object>{};

  /// 发布一个类型唯一的共享对象。
  void provide<T extends Object>(T value, {bool replace = false}) {
    if (!replace && _values.containsKey(T)) {
      throw StateError('类型 $T 已在 FxModContext 中注册');
    }
    _values[T] = value;
  }

  /// 获取指定类型的共享对象，不存在时抛出异常。
  T read<T extends Object>() {
    final Object? value = _values[T];
    if (value == null) {
      throw StateError('类型 $T 尚未在 FxModContext 中注册');
    }
    return value as T;
  }

  /// 尝试获取指定类型的共享对象。
  T? maybeRead<T extends Object>() => _values[T] as T?;

  /// 判断指定类型是否已经发布。
  bool contains<T extends Object>() => _values.containsKey(T);
}
