import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../data/global.dart' as global;

class PreferredDragToMoveWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  final bool canDouble;

  const PreferredDragToMoveWrapper(
      {super.key, required this.child, this.canDouble = false});

  @override
  Widget build(BuildContext context) {
    return DragToMoveWrapper(
      canDouble: canDouble,
      child: child,
    );
  }

  @override
  Size get preferredSize => child.preferredSize;
}

class DragToMoveWrapper extends StatelessWidget {
  final Widget child;
  final bool canDouble;

  const DragToMoveWrapper(
      {super.key, required this.child, this.canDouble = false});

  @override
  Widget build(BuildContext context) {
    if (!global.kIsDesk) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: !canDouble
          ? null
          : () async {
              bool isMax = await windowManager.isMaximized();
              if (isMax) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: child,
    );
  }
}
