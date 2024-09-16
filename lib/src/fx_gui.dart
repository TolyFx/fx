import 'package:flutter/material.dart';
import 'package:fx/src/pages/home_page.dart';

class FxGui extends StatelessWidget {
  const FxGui({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomePage(),
    );
  }
}

