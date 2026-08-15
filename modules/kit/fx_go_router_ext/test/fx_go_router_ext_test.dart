import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_go_router_ext/fx_go_router_ext.dart';
import 'package:tolyui_meta/tolyui_meta.dart';

void main() {
  test('按完整路径查找菜单路由及其父路由', () {
    final MenuRoute<void> root = MenuRoute<void>(
      path: '/',
      name: 'home',
      label: '首页',
      builder: _emptyPage,
      routes: <RouteBase>[
        MenuRoute<void>(
          path: 'settings',
          name: 'settings',
          label: '设置',
          builder: _emptyPage,
        ),
      ],
    );
    final GoRouter router = GoRouter(routes: <RouteBase>[root]);

    expect(router.find('/settings'), isA<MenuRoute<void>>());
    expect(router.find('/settings', findParent: true), same(root));

    router.dispose();
  });

  test('菜单投影保留标签与子级', () {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        MenuRoute<void>(
          path: '/',
          label: '首页',
          builder: _emptyPage,
          routes: <RouteBase>[
            MenuRoute<void>(path: 'settings', label: '设置', builder: _emptyPage),
          ],
        ),
      ],
    );

    final MenuNode menu = router.singleMenu<void>();

    final MenuNode home = menu.children.single;
    expect(home.data.label, '首页');
    expect(home.children.single.data.label, '设置');
    router.dispose();
  });
}

Widget _emptyPage(BuildContext context, GoRouterState state) {
  return const SizedBox.shrink();
}
