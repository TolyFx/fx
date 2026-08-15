import 'contribution.dart';

/// 一个经过校验、可用于诊断和可视化的模块路由描述。
final class FxRouteDescriptor {
  /// 声明路由的模块标识。
  final String moduleId;

  /// 路由所属的宿主挂载位置。
  final FxRouteMount mount;

  /// GoRouter 的全局唯一路由名称。
  final String? name;

  /// 从贡献根节点展开得到的完整路径。
  final String fullPath;

  /// 当前路由在贡献树中的深度，顶层为零。
  final int depth;

  /// 路由贡献面向诊断的可选标签。
  final String? debugLabel;

  const FxRouteDescriptor({
    required this.moduleId,
    required this.mount,
    required this.name,
    required this.fullPath,
    required this.depth,
    required this.debugLabel,
  });
}
