import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fx_trace/fx_trace.dart';
import 'package:tolyui_meta/tolyui_meta.dart';

import '../fx_event/fx_event.dart';

class FxNavigation extends StatefulWidget {
  final List<Widget> pages;
  final List<IconMenu> menus;

  const FxNavigation({
    super.key,
    required this.pages,
    required this.menus,
  });

  @override
  State<FxNavigation> createState() => _FxNavigationState();
}

class _FxNavigationState extends State<FxNavigation> with FxEmitterMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).scaffoldBackgroundColor;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: color,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: widget.pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: toPage,
          items: toMenus(),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> toMenus() {
    List<BottomNavigationBarItem> ret = [];
    for (IconMenu meta in widget.menus) {
      ret.add(BottomNavigationBarItem(
        icon: Icon(meta.icon),
        label: meta.label,
      ));
    }
    return ret;
  }

  void toPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void onEvent(FxEvent event) {
    if (event is NavToPage) {
      toPage(event.page);
    }
  }
}
