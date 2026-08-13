import 'package:flutter/widgets.dart';
import 'package:fx_mod/fx_mod.dart';
import 'package:go_router/go_router.dart';

import 'flutter_module.dart';
import 'routing/errors.dart';

/// 在 Flutter 应用中聚合模块声明并委托核心生命周期。
class FxFlutterModRuntime {
  /// 负责依赖图和生命周期的纯 Dart 内核。
  final FxModRuntime core;

  /// 按依赖顺序排列的 Flutter 模块。
  late final List<FxAppModule> _modules;

  /// 每个带局部路由模块独占的 Navigator Key。
  final Map<String, GlobalKey<NavigatorState>> _routeNavigatorKeys =
      <String, GlobalKey<NavigatorState>>{};

  /// 校验并缓存后的聚合路由。
  late final List<RouteBase> _routes;

  /// 所有模块共同决定的初始地址。
  late final String? _initialLocation;

  FxFlutterModRuntime(
    Iterable<FxAppModule> modules, {
    FxModContext? context,
  }) : core = FxModRuntime(modules, context: context) {
    _modules = core.modules.cast<FxAppModule>();
    _initialLocation = _resolveInitialLocation();
    _routes = _buildRoutes();
  }

  /// 模块间共享的类型化上下文。
  FxModContext get context => core.context;

  /// 当前核心生命周期阶段。
  FxModPhase get phase => core.phase;

  /// 依赖有序且不可修改的 Flutter 模块快照。
  List<FxAppModule> get modules => List<FxAppModule>.unmodifiable(_modules);

  /// 聚合后的根路由和模块局部 ShellRoute。
  List<RouteBase> get routes => List<RouteBase>.unmodifiable(_routes);

  /// 唯一模块声明的应用初始地址。
  String? get initialLocation => _initialLocation;

  /// 获取指定模块的局部 Navigator Key；无局部路由时返回空。
  GlobalKey<NavigatorState>? navigatorKeyOf(String moduleId) =>
      _routeNavigatorKeys[moduleId];

  /// 按依赖顺序聚合 Delegate，同类型 Delegate 只保留第一个。
  List<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    final Set<Type> delegateTypes = <Type>{};
    final List<LocalizationsDelegate<dynamic>> result =
        <LocalizationsDelegate<dynamic>>[];
    for (final FxAppModule module in _modules) {
      for (final LocalizationsDelegate<dynamic> delegate
          in module.localizationsDelegates) {
        if (delegateTypes.add(delegate.runtimeType)) result.add(delegate);
      }
    }
    return List<LocalizationsDelegate<dynamic>>.unmodifiable(result);
  }

  /// 聚合全部模块的语言区域并集，并保持首次声明顺序。
  List<Locale> get supportedLocales {
    final Set<Locale> seen = <Locale>{};
    final List<Locale> result = <Locale>[];
    for (final FxAppModule module in _modules) {
      for (final Locale locale in module.supportedLocales) {
        if (seen.add(locale)) result.add(locale);
      }
    }
    return List<Locale>.unmodifiable(result);
  }

  /// 依赖模块位于外层，消费模块位于内层，构建常驻 Widget 作用域。
  Widget wrap(BuildContext context, Widget child) {
    Widget current = child;
    for (final FxAppModule module in _modules.reversed) {
      current = module.wrap(context, current);
    }
    return current;
  }

  /// 使用模块聚合结果创建 GoRouter，同时保留宿主的全局策略配置权。
  GoRouter createRouter({
    GlobalKey<NavigatorState>? navigatorKey,
    GoRouterRedirect? redirect,
    GoRouterWidgetBuilder? errorBuilder,
    Listenable? refreshListenable,
    Iterable<NavigatorObserver> observers = const <NavigatorObserver>[],
    bool debugLogDiagnostics = false,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      routes: routes,
      initialLocation: initialLocation,
      redirect: redirect,
      errorBuilder: errorBuilder,
      refreshListenable: refreshListenable,
      observers: List<NavigatorObserver>.of(observers),
      debugLogDiagnostics: debugLogDiagnostics,
    );
  }

  /// 准备并启动全部模块。
  Future<void> start() => core.start();

  /// 向全部运行中模块广播事件。
  Future<void> dispatch(FxModEvent event) => core.dispatch(event);

  /// 逆序释放全部模块。
  Future<void> dispose() => core.dispose();

  /// 确认初始地址只能由一个模块声明。
  String? _resolveInitialLocation() {
    String? result;
    String? owner;
    for (final FxAppModule module in _modules) {
      final String? location = module.initialLocation;
      if (location == null) continue;
      if (result != null) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.duplicateInitialLocation,
          '模块 $owner 与 ${module.id} 同时声明了初始地址',
        );
      }
      result = location;
      owner = module.id;
    }
    return result;
  }

  /// 聚合根路由，并为每个局部路由模块创建独立 ShellRoute。
  List<RouteBase> _buildRoutes() {
    final List<RouteBase> result = <RouteBase>[];
    final Set<String> topPaths = <String>{};
    final Set<String> routeNames = <String>{};
    for (final FxAppModule module in _modules) {
      final List<RouteBase> rootRoutes = List<RouteBase>.of(module.rootRoutes);
      _validateRoutes(module.id, rootRoutes, topPaths, routeNames);
      result.addAll(rootRoutes);

      final List<RouteBase> localRoutes = List<RouteBase>.of(module.routes);
      if (localRoutes.isEmpty) continue;
      _validateRoutes(module.id, localRoutes, topPaths, routeNames);
      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'fx_mod:${module.id}');
      _routeNavigatorKeys[module.id] = navigatorKey;
      result.add(ShellRoute(
        navigatorKey: navigatorKey,
        observers: List<NavigatorObserver>.of(module.routeObservers),
        builder: (
          BuildContext context,
          GoRouterState state,
          Widget child,
        ) {
          return module.wrapRoutes(context, child);
        },
        routes: localRoutes,
      ));
    }
    return result;
  }

  /// 校验模块路由的顶层路径与全局名称唯一性。
  void _validateRoutes(
    String moduleId,
    List<RouteBase> routes,
    Set<String> topPaths,
    Set<String> routeNames,
  ) {
    for (final RouteBase route in routes) {
      if (route is GoRoute) {
        if (!route.path.startsWith('/')) {
          throw FxModFlutterException(
            FxModFlutterErrorCode.invalidTopRoutePath,
            '模块 $moduleId 的顶层路由 ${route.path} 必须使用绝对路径',
          );
        }
        if (!topPaths.add(route.path)) {
          throw FxModFlutterException(
            FxModFlutterErrorCode.duplicateRoutePath,
            '顶层路由路径 ${route.path} 重复',
          );
        }
      }
      _collectRouteNames(moduleId, route, routeNames);
    }
  }

  /// 递归检查 GoRouter 要求全局唯一的路由名称。
  void _collectRouteNames(
    String moduleId,
    RouteBase route,
    Set<String> routeNames,
  ) {
    if (route is GoRoute && route.name != null) {
      if (!routeNames.add(route.name!)) {
        throw FxModFlutterException(
          FxModFlutterErrorCode.duplicateRouteName,
          '模块 $moduleId 的路由名称 ${route.name} 重复',
        );
      }
    }
    for (final RouteBase child in route.routes) {
      _collectRouteNames(moduleId, child, routeNames);
    }
  }
}
