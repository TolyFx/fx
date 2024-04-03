import 'dart:async';

import 'package:toly_menu/toly_menu.dart';
import 'package:toly_menu_manager/data/model/menu_history.dart';

abstract class MenuRepository {

  /// 同步/异步 加载菜单树数据
  FutureOr<MenuNode> loadRootMenu();

  /// 同步/异步 加载菜单树激活信息
  /// List<String>: 展开项列表
  /// String: 激活项 id
  FutureOr<(List<String> ,String)> loadMenuActiveState();

  /// 同步/异步 加载菜单历史
  FutureOr<List<MenuHistory> > loadMenuHistory();

  /// 同步/异步 保存菜单历史
  FutureOr<void> saveMenuHistory(MenuHistory history);
  FutureOr<void> deleteMenuHistory(MenuHistory history);
}
