import 'package:flutter/material.dart';
import 'package:tolyui_meta/tolyui_meta.dart';

import 'fx_app/navigation/fx_navigation.dart';
import 'fx_app/fx_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: FxTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FxNavigation(
      pages: [
        Scaffold(),
         Scaffold(),
         Scaffold(),
         Scaffold(),
         Scaffold(),
      ],
      menus: [
        IconMenu(Icons.apps_rounded, route: '', label: 'Tab1'),
        IconMenu(Icons.apps_rounded, route: '', label: 'Tab2'),
        IconMenu(Icons.apps_rounded, route: '', label: 'Tab3'),
        IconMenu(Icons.apps_rounded, route: '', label: 'Tab4'),
        IconMenu(Icons.apps_rounded, route: '', label: 'Tab5'),
      ],
    );
  }
  // BottomNavigationBarItem(
//               icon: Icon(Icons.apps_rounded),
//               label: '工具',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.search_rounded),
//               label: '搜索',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.favorite_rounded),
//               label: '收藏',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.history_rounded),
//               label: '历史',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_rounded),
//               label: '我的',
//             )
}
