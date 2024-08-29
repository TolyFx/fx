import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_navigation/tolyui_navigation.dart';

class MenuRoute extends GoRoute {
  final String label;
  final IconData? icon;
  final Map<String, dynamic>? meta;

  MenuRoute({
    required super.path,
    required this.label,
    this.icon,
    this.meta,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes = const <RouteBase>[],
  });
}

extension GoRouterMenu on GoRouter {
  String get path => '/${routerDelegate.currentConfiguration.matches.last.matchedLocation}';

  MenuNode menuAt(String path){
    RouteBase? base = find(path,findParent: true);
    if(base==null) return MenuNode.fromMap({'children': []});
    List<Map<String, dynamic>> nodes = [];
    parserNodes(base, nodes);
    return MenuNode.fromMap({'children': nodes});
  }

  RouteBase? find(
      String path, {
        bool findParent = false,
      }) {
    Uri uri = Uri.parse(path);
    int pathLevel = uri.pathSegments.length;
    List<RouteBase> routers = configuration.routes;

    for (int i = 0; i < routers.length; i++) {
      RouteBase? ret = findByPath(null, routers[i], path, 0, pathLevel, '', findParent: findParent);
      if (ret != null) {
        return ret;
      }
    }

    return null;
  }

  RouteBase? findByPath(
      RouteBase? parent,
      RouteBase node,
      String path,
      int depth,
      int pathLevel,
      String prefix, {
        bool findParent = false,
      }) {
    String nodePath = '';
    if (node is GoRoute) {
      nodePath = node.path;
      if (prefix + nodePath == path) {
        return findParent ? parent : node;
      }
    }
    if (depth <= pathLevel) {
      if (node.routes.isNotEmpty) {
        for (int i = 0; i < node.routes.length; i++) {
          RouteBase? ret = findByPath(
            node,
            node.routes[i],
            path,
            depth + 1,
            pathLevel,
            prefix + nodePath,
            findParent: findParent,
          );
          if (ret != null) {
            return ret;
          }
        }
      }
    }
    return null;
  }

  MenuNode get singleMenu {
    List<RouteBase> routers = configuration.routes;
    List<Map<String, dynamic>> nodes = [];
    parserNodes(routers.first, nodes);
    return MenuNode.fromMap({'children': nodes});
  }

  Map<String, dynamic> parserNodes(RouteBase target, List<Map<String, dynamic>> map) {
    Map<String, dynamic> ret = {};
    if (target is MenuRoute) {
      ret['path'] = '/${target.path}';
      ret['label'] = target.label;
      ret['icon'] = target.icon;
      if (target.routes.isNotEmpty) {
        List<Map<String, dynamic>> children = [];
        for (int i = 0; i < target.routes.length; i++) {
          children.add(parserNodes(target.routes[i], []));
        }
        ret['children'] = children;
      }
    } else {
      List<RouteBase> routers = target.routes;
      for (int i = 0; i < routers.length; i++) {
        ret = parserNodes(routers[i], map);
        if (ret.isNotEmpty) {
          map.add(ret);
        }
      }
      return {};
    }
    return ret;
  }
}