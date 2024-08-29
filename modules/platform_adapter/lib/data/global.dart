import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart' as manager;
import 'package:window_manager/window_manager.dart';

bool kIsDesk = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

bool kIsDeskOrWeb = kIsWeb || kIsDesk;

bool kIsPhone = Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;

WindowManager windowManager = manager.windowManager;
