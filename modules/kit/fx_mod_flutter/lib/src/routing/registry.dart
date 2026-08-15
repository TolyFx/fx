import 'dart:collection';

import 'package:go_router/go_router.dart';

import 'contribution.dart';
import 'descriptor.dart';
import 'errors.dart';
import 'path.dart';

/// 对模块路由贡献完成一次校验后形成的只读注册表。
final class FxRouteRegistry {
  /// 按模块依赖顺序排列的贡献快照。
  final List<FxOwnedRouteContribution> _contributions;

  /// 宿主允许使用的稳定挂载位置。
  final Set<FxRouteMount> _registeredMounts;

  /// 展开贡献树后形成的静态路由描述。
  late final List<FxRouteDescriptor> _descriptors;

  /// 路由名称到声明模块的只读索引。
  late final Map<String, String> _ownersByRouteName;

  FxRouteRegistry({
    required Iterable<FxOwnedRouteContribution> contributions,
    required Set<FxRouteMount> registeredMounts,
  }) : _contributions = UnmodifiableListView<FxOwnedRouteContribution>(
         List<FxOwnedRouteContribution>.of(contributions),
       ),
       _registeredMounts = Set<FxRouteMount>.unmodifiable(registeredMounts) {
    _descriptors = _validateAndDescribe();
    _ownersByRouteName = Map<String, String>.unmodifiable(<String, String>{
      for (final FxRouteDescriptor descriptor in _descriptors)
        if (descriptor.name != null) descriptor.name!: descriptor.moduleId,
    });
  }

  /// 按模块拓扑与声明顺序排列的全部路由描述。
  List<FxRouteDescriptor> get descriptors => _descriptors;

  /// 返回指定挂载点中的全部顶层路由。
  List<RouteBase> routesAt(FxRouteMount mount) {
    return List<RouteBase>.unmodifiable(<RouteBase>[
      for (final FxOwnedRouteContribution owned in _contributions)
        if (owned.mount == mount) ...owned.routes,
    ]);
  }

  /// 返回挂载点中必须存在的顶层命名 GoRoute。
  GoRoute requireTopLevelRoute(FxRouteMount mount, String routeName) {
    for (final RouteBase route in routesAt(mount)) {
      if (route is GoRoute && route.name == routeName) return route;
    }
    throw FxModFlutterException(
      FxModFlutterErrorCode.missingMountedRoute,
      '挂载点 ${mount.id} 缺少顶层路由 $routeName',
    );
  }

  /// 返回声明指定命名路由的模块标识。
  String? ownerOf(String routeName) => _ownersByRouteName[routeName];

  /// 校验所有贡献并在同一遍历中生成静态描述。
  List<FxRouteDescriptor> _validateAndDescribe() {
    final Set<String> routePaths = {};
    final Set<String> routeNames = {};
    final List<FxRouteDescriptor> result = [];
    for (final FxOwnedRouteContribution owned in _contributions) {
      final FxRouteContribution contribution = owned.contribution;
      if (contribution.mount.id.trim().isEmpty || contribution.routes.isEmpty) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.invalidRouteContribution,
          '模块 ${owned.moduleId} 声明了空挂载点或空路由贡献',
        );
      }
      if (!_registeredMounts.contains(contribution.mount)) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.unknownRouteMount,
          '模块 ${owned.moduleId} 使用了未注册挂载点 ${contribution.mount.id}',
        );
      }
      for (final RouteBase route in contribution.routes) {
        _appendRoute(
          result,
          owned: owned,
          route: route,
          parentPath: '',
          depth: 0,
          routePaths: routePaths,
          routeNames: routeNames,
        );
      }
    }
    return List<FxRouteDescriptor>.unmodifiable(result);
  }

  /// 递归校验并展开一个贡献路由树。
  void _appendRoute(
    List<FxRouteDescriptor> result, {
    required FxOwnedRouteContribution owned,
    required RouteBase route,
    required String parentPath,
    required int depth,
    required Set<String> routePaths,
    required Set<String> routeNames,
  }) {
    String nextParentPath = parentPath;
    if (route is GoRoute) {
      if (parentPath.isEmpty && !route.path.startsWith('/')) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.invalidTopRoutePath,
          '模块 ${owned.moduleId} 的顶层路由 ${route.path} 必须使用绝对路径',
        );
      }
      nextParentPath = fxJoinRoutePath(parentPath, route.path);
      if (!routePaths.add(nextParentPath)) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.duplicateContributionPath,
          '模块 ${owned.moduleId} 的完整路由路径 $nextParentPath 重复',
        );
      }
      final String? routeName = route.name;
      if (routeName != null && !routeNames.add(routeName)) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.duplicateContributionName,
          '模块 ${owned.moduleId} 的路由名称 $routeName 重复',
        );
      }
      result.add(
        FxRouteDescriptor(
          moduleId: owned.moduleId,
          mount: owned.mount,
          name: routeName,
          fullPath: nextParentPath,
          depth: depth,
          debugLabel: owned.debugLabel,
        ),
      );
    }
    for (final RouteBase child in route.routes) {
      _appendRoute(
        result,
        owned: owned,
        route: child,
        parentPath: nextParentPath,
        depth: depth + 1,
        routePaths: routePaths,
        routeNames: routeNames,
      );
    }
  }
}
