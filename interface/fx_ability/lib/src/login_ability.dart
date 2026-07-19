import 'dart:async';

import 'package:flutter/material.dart';

/// 登录流程能力抽象接口
abstract class LoginAbility {
  /// 执行登录流程，返回是否登录成功
  FutureOr<bool> run(BuildContext context);
}
