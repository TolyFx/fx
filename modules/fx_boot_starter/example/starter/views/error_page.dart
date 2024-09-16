import 'package:flutter/material.dart';


class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          spacing: 20,
          children: [
            Text("初始化异常:\n$error",textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
