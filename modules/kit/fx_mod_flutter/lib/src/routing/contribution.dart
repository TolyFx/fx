import 'dart:collection';

import 'package:fx_mod/fx_mod.dart';
import 'package:go_router/go_router.dart';

/// 模块路由在宿主路由树中的挂载位置。
final class FxRouteMount {
  /// 挂载位置的稳定标识。
  final String id;

  const FxRouteMount(this.id);

  /// 应用根级路由的通用挂载位置。
  static const FxRouteMount root = FxRouteMount('fx.root');

  /// 模块独立 Navigator 的通用挂载位置。
  static const FxRouteMount moduleLocal = FxRouteMount('fx.module.local');

  @override
  bool operator ==(Object other) => other is FxRouteMount && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FxRouteMount($id)';
}

/// 一个模块向指定挂载位置声明的路由集合。
final class FxRouteContribution implements FxModContribution {
  /// 路由集合的目标挂载位置。
  final FxRouteMount mount;

  /// 当前贡献包含的不可修改路由列表。
  final List<RouteBase> routes;

  /// 用于诊断和可视化的可选标签。
  final String? debugLabel;

  FxRouteContribution({
    required this.mount,
    required Iterable<RouteBase> routes,
    this.debugLabel,
  }) : routes = UnmodifiableListView<RouteBase>(List<RouteBase>.of(routes));
}

/// 聚合后携带模块归属的路由贡献。
final class FxOwnedRouteContribution {
  /// 提供当前贡献的模块标识。
  final String moduleId;

  /// 模块声明的原始路由贡献。
  final FxRouteContribution contribution;

  const FxOwnedRouteContribution({
    required this.moduleId,
    required this.contribution,
  });

  /// 路由集合的目标挂载位置。
  FxRouteMount get mount => contribution.mount;

  /// 当前贡献包含的路由列表。
  List<RouteBase> get routes => contribution.routes;

  /// 用于诊断和可视化的可选标签。
  String? get debugLabel => contribution.debugLabel;
}
