/// 一个可寻址页面在宿主中的稳定路由身份。
final class FxRouteSpec {
  /// GoRouter 使用的全局唯一名称。
  final String name;

  /// GoRouter 声明使用的路径。
  final String path;

  const FxRouteSpec({required this.name, required this.path});

  @override
  bool operator ==(Object other) {
    return other is FxRouteSpec && other.name == name && other.path == path;
  }

  @override
  int get hashCode => Object.hash(name, path);

  @override
  String toString() => 'FxRouteSpec(name: $name, path: $path)';
}
