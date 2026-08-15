import 'package:flutter/widgets.dart';
import 'package:fx_mod/fx_mod.dart';
import 'package:go_router/go_router.dart';

import 'routing/contribution.dart';

/// 可由 Flutter 宿主拼装的模块。
///
/// 每个模块自行声明国际化和 Widget 作用域，宿主无需了解模块内部依赖。
abstract class FxAppModule extends FxModule {
  const FxAppModule();

  /// 当前模块提供的国际化代理。
  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      const <LocalizationsDelegate<dynamic>>[];

  /// 当前模块能够处理的语言区域。
  Iterable<Locale> get supportedLocales => const <Locale>[];

  /// 直接挂载到应用根 Navigator 的全屏路由。
  Iterable<RouteBase> get rootRoutes => const <RouteBase>[];

  /// 挂载到当前模块局部 Navigator 的路由。
  Iterable<RouteBase> get routes => const <RouteBase>[];

  /// 按宿主挂载位置声明的路由贡献。
  ///
  /// 新应用应优先使用该接口；[rootRoutes] 与 [routes] 仅保留旧版兼容。
  Iterable<FxRouteContribution> get routeContributions =>
      const <FxRouteContribution>[];

  /// 当前模块建议的应用初始地址，同一应用最多只能有一个模块声明。
  String? get initialLocation => null;

  /// 当前模块局部 Navigator 的观察者。
  Iterable<NavigatorObserver> get routeObservers => const <NavigatorObserver>[];

  /// 为当前模块建立常驻 Widget 作用域。
  ///
  /// 默认不添加包装；状态管理模块可在这里注入 Provider 或其他 InheritedWidget。
  Widget wrap(BuildContext context, Widget child) => child;

  /// 为当前模块的局部 Navigator 建立状态作用域。
  Widget wrapRoutes(BuildContext context, Widget child) => child;
}
