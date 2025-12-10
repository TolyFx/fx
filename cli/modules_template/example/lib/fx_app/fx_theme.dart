import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FxTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF757575);
  static const Color accentColor = Color(0xFFFF9800);

  static ThemeData get lightTheme {
    double dividerHeight =
        1 / PlatformDispatcher.instance.views.first.devicePixelRatio;

    return ThemeData(
      useMaterial3: true,
      visualDensity: const VisualDensity(vertical: -2),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 14), // 输入文字字号
      ),
      dividerTheme: DividerThemeData(
        // color: const Color(0xffDEE0E2),
        color: const Color(0xffedeef2),
        space: dividerHeight,
        thickness: dividerHeight,
      ),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blue,
          selectionHandleColor: Colors.blue),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
            fontSize: 18,
            color: Color(0xff333333),
            fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      tabBarTheme: TabBarTheme(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: const Color(0xffedeef2),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(fontSize: 14, color: Color(0xff999999)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
