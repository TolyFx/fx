import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_event/fx_event.dart';
import 'package:fx_mod_flutter/fx_mod_flutter.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('路由规格稳定绑定名称与路径', () {
    const FxRouteSpec route = FxRouteSpec(
      name: 'feature.detail',
      path: '/feature/:id',
    );

    expect(route.name, 'feature.detail');
    expect(route.path, '/feature/:id');
    expect(
      route,
      const FxRouteSpec(name: 'feature.detail', path: '/feature/:id'),
    );
  });

  test('按依赖顺序聚合国际化并去除同类型 Delegate', () {
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _FeatureModule(),
      const _CoreModule(),
    ]);

    expect(
      runtime.localizationsDelegates.map(
        (LocalizationsDelegate<dynamic> delegate) => delegate.runtimeType,
      ),
      <Type>[_CoreDelegate, _FeatureDelegate],
    );
    expect(runtime.supportedLocales, const <Locale>[
      Locale('zh'),
      Locale('en'),
      Locale('ja'),
    ]);
  });

  testWidgets('依赖模块作用域包裹消费模块作用域', (WidgetTester tester) async {
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _FeatureModule(),
      const _CoreModule(),
    ]);

    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) => runtime.wrap(
          context,
          const Text('content', textDirection: TextDirection.ltr),
        ),
      ),
    );

    final Finder core = find.byKey(const ValueKey<String>('core'));
    final Finder feature = find.byKey(const ValueKey<String>('feature'));
    final Finder content = find.text('content');
    expect(find.ancestor(of: feature, matching: core), findsOneWidget);
    expect(find.ancestor(of: content, matching: feature), findsOneWidget);
  });

  test('模块局部路由生成独立 ShellRoute 和 Navigator', () {
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _RoutedModule(),
    ]);

    expect(runtime.initialLocation, '/feature');
    expect(runtime.routes, hasLength(2));
    expect(runtime.routes.first, isA<GoRoute>());
    expect(runtime.routes.last, isA<ShellRoute>());
    expect(runtime.navigatorKeyOf('routed'), isNotNull);
  });

  testWidgets('局部导航页面位于模块路由作用域中', (WidgetTester tester) async {
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _RoutedModule(),
    ]);
    final GoRouter router = runtime.createRouter();

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('feature'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('feature'),
        matching: find.byKey(const ValueKey<String>('route-scope')),
      ),
      findsOneWidget,
    );
    router.dispose();
  });

  test('拒绝重复顶层路径、重复名称和多个初始地址', () {
    expect(
      () => FxFlutterModRuntime(<FxAppModule>[
        const _ConflictModule('a', '/same', routeName: 'a'),
        const _ConflictModule('b', '/same', routeName: 'b'),
      ]),
      throwsA(_flutterModCode(FxModFlutterErrorCode.duplicateRoutePath)),
    );
    expect(
      () => FxFlutterModRuntime(<FxAppModule>[
        const _ConflictModule('a', '/a', routeName: 'same'),
        const _ConflictModule('b', '/b', routeName: 'same'),
      ]),
      throwsA(_flutterModCode(FxModFlutterErrorCode.duplicateRouteName)),
    );
    expect(
      () => FxFlutterModRuntime(<FxAppModule>[
        const _ConflictModule('a', '/a', initialLocation: '/a'),
        const _ConflictModule('b', '/b', initialLocation: '/b'),
      ]),
      throwsA(_flutterModCode(FxModFlutterErrorCode.duplicateInitialLocation)),
    );
  });

  test('按依赖顺序聚合指定挂载点的路由贡献', () {
    const FxRouteMount featureMount = FxRouteMount('host.feature');
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _ContributingModule(
        'feature',
        featureMount,
        '/feature',
        dependencies: <String>{'core'},
      ),
      const _ContributingModule('core', featureMount, '/core'),
    ]);

    runtime.validateRouteContributions(<FxRouteMount>{featureMount});

    expect(
      runtime
          .contributionsAt(featureMount)
          .map((FxOwnedRouteContribution item) => item.moduleId),
      <String>['core', 'feature'],
    );
  });

  test('路由注册表统一提供挂载查询、静态描述和模块归属', () {
    const FxRouteMount featureMount = FxRouteMount('host.feature');
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _ContributingModule('core', featureMount, '/core'),
      const _ContributingModule(
        'feature',
        featureMount,
        '/feature',
        routeName: 'feature',
      ),
    ]);

    final FxRouteRegistry registry = runtime.createRouteRegistry(<FxRouteMount>{
      featureMount,
    });

    expect(registry.routesAt(featureMount), hasLength(2));
    expect(
      registry.requireTopLevelRoute(featureMount, 'feature').path,
      '/feature',
    );
    expect(registry.descriptors, hasLength(2));
    expect(registry.descriptors.last.fullPath, '/feature');
    expect(registry.ownerOf('feature'), 'feature');
  });

  test('缺少宿主要求的顶层命名路由时返回稳定框架错误', () {
    const FxRouteMount featureMount = FxRouteMount('host.feature');
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _ContributingModule('feature', featureMount, '/feature'),
    ]);
    final FxRouteRegistry registry = runtime.createRouteRegistry(<FxRouteMount>{
      featureMount,
    });

    expect(
      () => registry.requireTopLevelRoute(featureMount, 'missing'),
      throwsA(_flutterModCode(FxModFlutterErrorCode.missingMountedRoute)),
    );
  });

  test('多个 Navigator 的路由事件汇入同一模块感知流', () async {
    const FxRouteMount featureMount = FxRouteMount('host.feature');
    final FxFlutterModRuntime runtime = FxFlutterModRuntime(<FxAppModule>[
      const _ContributingModule(
        'feature',
        featureMount,
        '/feature',
        routeName: 'feature',
      ),
    ]);
    final FxRouteRegistry registry = runtime.createRouteRegistry(<FxRouteMount>{
      featureMount,
    });
    final FxRouteObserverHub hub = FxRouteObserverHub(registry: registry);
    final FxEventSource<FxRouteEvent> source = hub;
    final List<FxRouteEvent> events = [];
    final StreamSubscription<FxRouteEvent> subscription = source.events.listen(
      events.add,
    );
    final NavigatorObserver root = hub.observer('root');
    final MaterialPageRoute<void> route = MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'feature'),
      builder: _buildEmptyPage,
    );

    root.didPush(route, null);
    root.didPop(route, null);

    expect(events.map((FxRouteEvent event) => event.sequence), <int>[1, 2]);
    expect(events.first.navigatorId, 'root');
    expect(events.first.ownerModuleId, 'feature');
    expect(events.first, isA<FxEvent>());
    expect(events.last.action, FxRouteAction.pop);

    await subscription.cancel();
    await hub.dispose();
  });

  test('拒绝未知挂载点、重复完整路径和重复路由名称', () {
    const FxRouteMount knownMount = FxRouteMount('host.known');
    const FxRouteMount unknownMount = FxRouteMount('host.unknown');
    expect(
      () => FxFlutterModRuntime(<FxAppModule>[
        const _ContributingModule('feature', unknownMount, '/feature'),
      ]).validateRouteContributions(<FxRouteMount>{knownMount}),
      throwsA(_flutterModCode(FxModFlutterErrorCode.unknownRouteMount)),
    );
    expect(
      () => FxFlutterModRuntime(<FxAppModule>[
        const _ContributingModule('a', knownMount, '/same'),
        const _ContributingModule('b', knownMount, '/same'),
      ]).validateRouteContributions(<FxRouteMount>{knownMount}),
      throwsA(_flutterModCode(FxModFlutterErrorCode.duplicateContributionPath)),
    );
    expect(
      () => FxFlutterModRuntime(<FxAppModule>[
        const _ContributingModule('a', knownMount, '/a', routeName: 'same'),
        const _ContributingModule('b', knownMount, '/b', routeName: 'same'),
      ]).validateRouteContributions(<FxRouteMount>{knownMount}),
      throwsA(_flutterModCode(FxModFlutterErrorCode.duplicateContributionName)),
    );
  });
}

Matcher _flutterModCode(FxModFlutterErrorCode code) {
  return isA<FxModFlutterException>().having(
    (FxModFlutterException error) => error.code,
    'code',
    code,
  );
}

Widget _buildEmptyPage(BuildContext context) {
  return const SizedBox.shrink();
}

class _CoreModule extends FxAppModule {
  const _CoreModule();

  @override
  String get id => 'core';

  @override
  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      const <LocalizationsDelegate<dynamic>>[_CoreDelegate(), _CoreDelegate()];

  @override
  Iterable<Locale> get supportedLocales => const <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  @override
  Widget wrap(BuildContext context, Widget child) {
    return KeyedSubtree(key: const ValueKey<String>('core'), child: child);
  }
}

class _FeatureModule extends FxAppModule {
  const _FeatureModule();

  @override
  String get id => 'feature';

  @override
  Set<String> get dependencies => const <String>{'core'};

  @override
  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      const <LocalizationsDelegate<dynamic>>[_FeatureDelegate()];

  @override
  Iterable<Locale> get supportedLocales => const <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  @override
  Widget wrap(BuildContext context, Widget child) {
    return KeyedSubtree(key: const ValueKey<String>('feature'), child: child);
  }
}

class _CoreDelegate extends LocalizationsDelegate<String> {
  const _CoreDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<String> load(Locale locale) async => 'core';

  @override
  bool shouldReload(_CoreDelegate old) => false;
}

class _FeatureDelegate extends LocalizationsDelegate<String> {
  const _FeatureDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<String> load(Locale locale) async => 'feature';

  @override
  bool shouldReload(_FeatureDelegate old) => false;
}

class _RoutedModule extends FxAppModule {
  const _RoutedModule();

  @override
  String get id => 'routed';

  @override
  String get initialLocation => '/feature';

  @override
  Iterable<RouteBase> get rootRoutes => <RouteBase>[
    GoRoute(path: '/login', builder: _buildLogin),
  ];

  @override
  Iterable<RouteBase> get routes => <RouteBase>[
    GoRoute(
      path: '/feature',
      builder: _buildFeature,
      routes: <RouteBase>[GoRoute(path: 'detail', builder: _buildDetail)],
    ),
  ];

  static Widget _buildLogin(BuildContext context, GoRouterState state) {
    return const Text('login', textDirection: TextDirection.ltr);
  }

  static Widget _buildFeature(BuildContext context, GoRouterState state) {
    return const Text('feature', textDirection: TextDirection.ltr);
  }

  static Widget _buildDetail(BuildContext context, GoRouterState state) {
    return const Text('detail', textDirection: TextDirection.ltr);
  }

  @override
  Widget wrapRoutes(BuildContext context, Widget child) {
    return KeyedSubtree(
      key: const ValueKey<String>('route-scope'),
      child: child,
    );
  }
}

class _ConflictModule extends FxAppModule {
  /// 测试模块标识。
  @override
  final String id;

  /// 测试路由路径。
  final String routePath;

  /// 测试路由名称。
  final String? routeName;

  /// 测试初始地址。
  @override
  final String? initialLocation;

  const _ConflictModule(
    this.id,
    this.routePath, {
    this.routeName,
    this.initialLocation,
  });

  @override
  Iterable<RouteBase> get routes => <RouteBase>[
    GoRoute(path: routePath, name: routeName, builder: _buildPage),
  ];

  static Widget _buildPage(BuildContext context, GoRouterState state) {
    return const SizedBox.shrink();
  }
}

class _ContributingModule extends FxAppModule {
  /// 当前测试模块的稳定标识。
  @override
  final String id;

  /// 当前模块贡献的宿主挂载位置。
  final FxRouteMount mount;

  /// 当前模块贡献的顶层路径。
  final String routePath;

  /// 当前模块贡献的可选路由名称。
  final String? routeName;

  /// 当前模块依赖的其他模块标识。
  @override
  final Set<String> dependencies;

  const _ContributingModule(
    this.id,
    this.mount,
    this.routePath, {
    this.routeName,
    this.dependencies = const <String>{},
  });

  @override
  Iterable<FxRouteContribution> get routeContributions => <FxRouteContribution>[
    FxRouteContribution(
      mount: mount,
      routes: <RouteBase>[
        GoRoute(path: routePath, name: routeName, builder: _buildPage),
      ],
    ),
  ];

  static Widget _buildPage(BuildContext context, GoRouterState state) {
    return const SizedBox.shrink();
  }
}
