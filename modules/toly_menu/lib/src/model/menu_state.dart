import 'menu_data.dart';

class MenuState {
  final List<String> expandMenus;
  final String activeMenu;
  final List<MenuNode> items;

  MenuState({
   required this.expandMenus,
   required this.activeMenu,
   required this.items,
  });

  MenuState copyWith({
    List<String>? expandMenus,
    String? activeMenu,
    List<MenuNode>? items,
}){
    return MenuState(
        expandMenus:expandMenus??this.expandMenus,
      activeMenu:activeMenu??this.activeMenu,
      items:items??this.items,
    );
  }
}
