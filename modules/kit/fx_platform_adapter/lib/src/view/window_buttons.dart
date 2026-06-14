import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatefulWidget {
  final List<Widget>? actions;
  final double size;

  const WindowButtons({
    super.key,
    this.actions,
    this.size = 30,
  });

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Align(
      alignment: Alignment.topRight,
      child: Wrap(
        spacing: 5,
        children: [
          if (widget.actions != null) ...widget.actions!,
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: WindowCaptionButton.minimize(
              brightness: brightness,
              onPressed: () async {
                bool isMinimized = await windowManager.isMinimized();
                if (isMinimized) {
                  windowManager.restore();
                } else {
                  windowManager.minimize();
                }
              },
            ),
          ),
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: FutureBuilder<bool>(
              future: windowManager.isMaximized(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data == true) {
                  return WindowCaptionButton.unmaximize(
                    brightness: brightness,
                    onPressed: () async {
                      await windowManager.unmaximize();
                      setState(() {});
                    },
                  );
                }
                return WindowCaptionButton.maximize(
                  brightness: brightness,
                  onPressed: () async {
                    await windowManager.maximize();
                    setState(() {});
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: widget.size,
            width: widget.size,
            child: WindowCaptionButton.close(
              brightness: brightness,
              onPressed: () {
                windowManager.close();
              },
            ),
          ),
        ],
      ),
    );
  }
}
