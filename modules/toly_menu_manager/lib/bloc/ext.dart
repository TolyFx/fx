import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toly_menu/toly_menu.dart';

import '../data/model/menu_history.dart';
import 'menu_history_bloc.dart';
import 'menu_router_bloc.dart';

extension BlocActionContext on BuildContext {

  void selectMenu(MenuNode menu) => read<MenuRouterBloc>().selectMenu(menu);

  String? get activeMenu=> read<MenuRouterBloc>().activeMenu;

  void loadMenu() => read<MenuRouterBloc>().loadMenu();

  void addHistory(String title, String path) =>
      read<MenuHistoryBloc>().addHistory(title, path);
  void activeHistory(String path) =>
      read<MenuHistoryBloc>().activeHistory(path);

  void removeHistory(MenuHistory history) =>
      read<MenuHistoryBloc>().removeHistory(history);
}
